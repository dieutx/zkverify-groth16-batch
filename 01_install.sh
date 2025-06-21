#!/usr/bin/env bash
set -e

echo "[+] Install deps: Rust, Circom 2.1.5, SnarkJS, Node, build tools"

sudo apt update -y \
 && sudo apt install -y build-essential git curl wget nodejs npm

# Rust
if ! command -v cargo &>/dev/null; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Circom binary
if ! command -v circom &>/dev/null; then
  wget -qO circom https://github.com/iden3/circom/releases/download/v2.1.5/circom-linux-amd64
  chmod +x circom && sudo mv circom /usr/local/bin/
fi

# SnarkJS CLI
npm install -g snarkjs

echo "[✔] Done install"
