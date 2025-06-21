#!/usr/bin/env bash
set -e
ROOT=$(pwd)
WORK=$ROOT/real-proof
mkdir -p "$WORK"

# 2.1  Tạo circuit
cat > "$WORK/sum.circom" <<'EOF'
pragma circom 2.0.0;
template SumCircuit() {
  signal input a;
  signal input b;
  signal output c;
  c <== a + b;
}
component main = SumCircuit();
EOF

echo "[+] Compile circuit"
circom "$WORK/sum.circom" --r1cs --wasm --sym -o "$WORK"

# 2.2  Tải ptau
PTAU=$ROOT/pot12_final.ptau
[ -f "$PTAU" ] || wget -qO "$PTAU" https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_10.ptau

# 2.3  Setup zkey + vk
snarkjs groth16 setup         \
        "$WORK/sum.r1cs"      \
        "$PTAU"               \
        "$WORK/sum.zkey"

snarkjs zkey export verificationkey \
        "$WORK/sum.zkey"           \
        "$WORK/verification_key.json"

echo "[✔] Circuit ready"
