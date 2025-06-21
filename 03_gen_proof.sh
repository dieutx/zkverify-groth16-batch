#!/usr/bin/env bash
# Usage: bash 03_gen_proof.sh <iteration>
set -e
i=${1:-0}
ROOT=$(pwd)
WORK=$ROOT/real-proof
DATA=$ROOT/data
mkdir -p "$DATA"

# Random a,b
a=$(shuf -i 1-5000 -n 1)
b=$(shuf -i 1-5000 -n 1)

cat > "$WORK/input.json" <<EOF
{ "a": "$a", "b": "$b" }
EOF

snarkjs wtns calculate           \
        "$WORK/sum_js/sum.wasm"  \
        "$WORK/input.json"       \
        "$WORK/witness.wtns"

snarkjs groth16 prove            \
        "$WORK/sum.zkey"         \
        "$WORK/witness.wtns"     \
        "$WORK/proof.json"       \
        "$WORK/public.json"

# Lưu bản theo số lần lặp (để debug dễ)
cp "$WORK/proof.json"           "$DATA/proof_$i.json"
cp "$WORK/public.json"          "$DATA/public_$i.json"
cp "$WORK/verification_key.json" "$DATA/verification_key.json"
echo "[+] Proof #$i generated (a=$a, b=$b)"
