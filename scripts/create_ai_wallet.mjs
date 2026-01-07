import fs from "fs";
import path from "path";
import { Wallet } from "ethers";
import dotenv from "dotenv";

dotenv.config();

const ROOT = process.cwd();
const ENV_PATH = path.join(ROOT, ".env");
const AI_KEY_PATH = path.join(ROOT, "environments", "ai.key");

console.log("🤖 Génération du AI_COORDINATOR...");

// Sécurité : ne jamais écraser
if (fs.existsSync(AI_KEY_PATH)) {
  console.log("⚠️ AI_COORDINATOR déjà existant. Abandon.");
  process.exit(0);
}

// Création du wallet
const wallet = Wallet.createRandom();

const address = wallet.address;
const privateKey = wallet.privateKey;

// Sauvegarde clé privée (isolée)
fs.writeFileSync(AI_KEY_PATH, privateKey, { mode: 0o600 });

// Injection dans .env
let env = fs.existsSync(ENV_PATH)
  ? fs.readFileSync(ENV_PATH, "utf-8")
  : "";

if (!env.includes("AI_COORDINATOR")) {
  env += `\nAI_COORDINATOR=${address}\n`;
} else {
  env = env.replace(
    /^AI_COORDINATOR=.*$/m,
    `AI_COORDINATOR=${address}`
  );
}

fs.writeFileSync(ENV_PATH, env);

console.log("✅ AI_COORDINATOR créé avec succès");
console.log("📬 Adresse :", address);
console.log("🔐 Clé privée stockée dans environments/ai.key");
