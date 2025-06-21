// index.js – submit Noir UltraPlonk proof to zkVerify via Horizen Labs relayer
// ---------------------------------------------------------------
// 1. npm init -y && npm pkg set type=module
// 2. npm i axios dotenv
// 3. Put API_KEY=YOUR_KEY in a .env file at project root
// 4. Place proof, vk (and optional public.json) in ./target/
// 5. node index.js

import axios from 'axios';
import fs from 'fs';
import dotenv from 'dotenv';

dotenv.config();

const API_URL = 'https://relayer-api.horizenlabs.io/api/v1';

/**
 * Helper: load a file and return its base‑64 string.
 */
const loadB64 = (path) => fs.readFileSync(path).toString('base64');

// --- Load artifacts ---------------------------------------------------------
const base64Proof = loadB64('./target/proof');            // binary file from `bb prove`
const base64Vk    = loadB64('./target/vk');               // binary file from `bb write_vk`

// Try to determine how many public inputs the circuit exposes
let numberOfPublicInputs = 1; // sensible fallback
try {
  const pub = JSON.parse(fs.readFileSync('./target/public.json', 'utf8'));
  if (Array.isArray(pub)) numberOfPublicInputs = pub.length;
} catch (_) {
  // no public.json – keep default
}

// --- Main workflow ----------------------------------------------------------
async function main() {
  // 1) Submit proof for verification
  const params = {
    proofType: 'ultraplonk',
    vkRegistered: false,
    proofOptions: {
      numberOfPublicInputs,
    },
    proofData: {
      proof: base64Proof,
      vk: base64Vk,
    },
  };

  const { data: submitRes } = await axios.post(
    `${API_URL}/submit-proof/${process.env.API_KEY}`,
    params,
  );
  console.log('Submitted:', submitRes);

  if (submitRes.optimisticVerify !== 'success') {
    console.error('❌ Optimistic verification failed – check proof & vk');
    return;
  }

  // 2) Poll status until finalized
  while (true) {
    const { data: job } = await axios.get(
      `${API_URL}/job-status/${process.env.API_KEY}/${submitRes.jobId}`,
    );

    if (job.status === 'Finalized') {
      console.log('✅ Finalized');
      console.log(job); // log entire job object
      break;
    }

    console.log('Status:', job.status);
    console.log('Waiting 5 s…');
    await new Promise((r) => setTimeout(r, 5000));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
