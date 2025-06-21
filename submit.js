// submit.js
import axios from "axios";
import fs from "fs";
import dotenv from "dotenv";
dotenv.config();

const API_URL = "https://relayer-api.horizenlabs.io/api/v1";

export async function submit(i) {
  const proof  = JSON.parse(fs.readFileSync(`./data/proof_${i}.json`));
  const pub    = JSON.parse(fs.readFileSync(`./data/public_${i}.json`));
  const vk     = JSON.parse(fs.readFileSync(`./data/verification_key.json`));

  const params = {
    proofType: "groth16",
    vkRegistered: false,
    proofOptions: { library: "snarkjs", curve: "bn128" },
    proofData: { proof, publicSignals: pub, vk }
  };

  const { data } = await axios.post(
      `${API_URL}/submit-proof/${process.env.API_KEY}`, params);
  console.log(`[${i}] → jobId ${data.jobId}`);

  // Poll tới khi Finalized
  while (true) {
    const { data: job } = await axios.get(
      `${API_URL}/job-status/${process.env.API_KEY}/${data.jobId}`);
    if (job.status === "Finalized") {
      console.log(`[${i}] ✅ Finalized`);
      break;
    }
    await new Promise(r => setTimeout(r, 5000));
  }
}
