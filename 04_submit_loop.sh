#!/usr/bin/env bash
set -e
COUNT=1000

for ((i=1; i<=COUNT; i++)); do
  echo "=== Round $i/$COUNT ==="
  bash 03_gen_proof.sh "$i"
  node -e "import('./submit.js').then(m => m.submit($i))"
done
