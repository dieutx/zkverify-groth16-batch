#!/usr/bin/env bash
# ------------------------------------------------------------
# UltraPlonk proof generator for the Noir “hello_world” circuit
# ------------------------------------------------------------
# Usage:  ./generate_proof.sh          # installs bb v0.76.4 (default)
#         ./generate_proof.sh 0.76.0   # installs another bb version
# ------------------------------------------------------------

set -euo pipefail

BB_VERSION="${1:-0.76.4}"          # last UltraPlonk-compatible release
PROJECT="hello_world"

echo "🛠  Installing Noir toolkit (noirup)…"
curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/heads/main/install | bash
export PATH="$HOME/.nargo/bin:$PATH"
noirup                                   # always fetches the latest Noir

echo "🛠  Installing Barretenberg backend (bb) v${BB_VERSION}…"
curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/refs/heads/master/barretenberg/bbup/install | bash
# 👉 ADD THIS LINE: make bbup available immediately
export PATH="$HOME/.bb:$PATH"          # ~/.bb holds the bbup binary
bbup -v "$BB_VERSION"

echo "📁  Creating fresh project ${PROJECT}/"
rm -rf "$PROJECT"
nargo new "$PROJECT"
cd "$PROJECT"

# --- Random inputs ----------------------------------------------------------
RANGE_X_MIN=1   RANGE_X_MAX=100
RANGE_Y_MIN=1   RANGE_Y_MAX=100
rand_range() { echo $(( RANDOM % ($2 - $1 + 1) + $1 )); }

X_VAL=$(rand_range $RANGE_X_MIN $RANGE_X_MAX)
Y_VAL=$(rand_range $RANGE_Y_MIN $RANGE_Y_MAX)

cat > Prover.toml <<EOF
x = "${X_VAL}"
y = "${Y_VAL}"
EOF
echo "🎲  Random inputs: x=${X_VAL}, y=${Y_VAL}"

# --- Compile, execute, and prove -------------------------------------------
echo "🚀  Compiling circuit & generating witness…"
nargo execute

echo "🔑  Generating proof & verifying key…"
bb prove    -b ./target/${PROJECT}.json -w ./target/${PROJECT}.gz -o ./target/proof
bb write_vk -b ./target/${PROJECT}.json                       -o ./target/vk

echo -e "\n✅  Done! Files created:"
ls -lh ./target/proof ./target/vk
