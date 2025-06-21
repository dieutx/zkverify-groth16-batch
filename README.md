# zkVerify Relayer Demo

Minimal scripts to **generate Groth16 proofs with Circom 2.1.5** and **submit them to Horizen Labs zkVerify**.

---

## 🚀 Quick start

```bash
# clone / enter repo
git clone https://github.com/dieutx/zkverify-groth16-batch.git
cd zkverify-groth16-batch

# 1. install tool‑chain (Rust, Circom, SnarkJS, Node)
bash 01_install.sh

# 2. compile circuit & keys (one‑time)
bash 02_compile.sh

# 3. Node deps + API key (one‑time)
npm init -y
npm pkg set type=module
npm install axios dotenv
echo 'API_KEY=YOUR_API_KEY_HERE' > .env

# 4. generate + submit 100 proofs (edit COUNT in script)
bash 04_submit_loop.sh
```

---

## 🗂️ Files

```
01_install.sh   02_compile.sh   03_gen_proof.sh   04_submit_loop.sh
submit.js       .env            real-proof/       data/
```

| File / Folder           | Purpose                                                                                                  |
| ----------------------- | -------------------------------------------------------------------------------------------------------- |
| **01\_install.sh**      | Install Rust, Circom 2.1.5 binary, SnarkJS, Node & build packages. Run **once**.                         |
| **02\_compile.sh**      | Compile `sum.circom`, download ptau, create Groth16 proving/verification keys. Run **once per circuit**. |
| **03\_gen\_proof.sh**   | Generate random inputs (1‑5000), build witness, produce `proof.json` & `public.json`.                    |
| **04\_submit\_loop.sh** | Loop (default = 100×): call *03\_gen\_proof* then post each proof to zkVerify until *Finalized*.         |
| **submit.js**           | Node ES‑module that hits `/submit-proof` and polls `/job-status`.                                        |
| **real-proof/**         | Compiled circuit, wasm, zkey, witness plus latest JSON artefacts.                                        |
| **data/**               | Proof/public files saved per iteration (`proof_1.json`…), plus `verification_key.json`.                  |
| **.env**                | Stores `API_KEY` for relayer. **Never commit this!**                                                     |

---

## 🔧 Tips

- Change proof count: `COUNT=…` inside **04\_submit\_loop.sh**.
- Swap in your own circuit before running **02\_compile.sh**.
- Adjust input range in **03\_gen\_proof.sh** (`shuf -i min-max`).

---

MIT License — no warranty.

