import { ethers } from "ethers";
import OmniUtilArtifact from "./utils/omniutil_abi.json";

/* ================= CONFIG ================= */
const INFURA_PROJECT_ID = "d0b22fefc3b34fa2b9cf181f2425e70b";
const RPC_URL = `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`;

const CONTRACT_ADDRESS = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";
const ABI = OmniUtilArtifact.abi;

/* ================= PROVIDER ================= */
let provider: ethers.JsonRpcProvider;
let contract: ethers.Contract;

/* ================= UTILS ================= */
function format(value: any): string {
  if (typeof value === "bigint") return value.toString();
  if (Array.isArray(value)) return JSON.stringify(value.map(format));
  if (typeof value === "object" && value !== null) {
    try {
      return JSON.stringify(value);
    } catch {
      return String(value);
    }
  }
  return String(value);
}

function status(text: string, ok = true) {
  const el = document.getElementById("status");
  if (!el) return;
  el.textContent = text;
  el.style.color = ok ? "green" : "red";
}

/* ================= UI ================= */
function baseUI(root: HTMLElement) {
  root.innerHTML = `
    <h1>OmniUtil — On-chain Contract Explorer</h1>

    <p id="status">⏳ Initialisation…</p>

    <p><b>Réseau :</b> Ethereum Mainnet</p>
    <p><b>RPC :</b> Infura</p>
    <p><b>Contrat :</b> ${CONTRACT_ADDRESS}</p>

    <button id="reload">🔄 Recharger</button>

    <table border="1" cellpadding="6" cellspacing="0">
      <thead>
        <tr>
          <th>Fonction</th>
          <th>Résultat</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody id="tbody"></tbody>
    </table>

    <p style="margin-top:20px;font-size:12px">
      © OmniUtil — Transparency by design
    </p>
  `;
}

/* ================= CORE ================= */
async function load(root: HTMLElement) {
  baseUI(root);

  try {
    provider = new ethers.JsonRpcProvider(RPC_URL);
    await provider.getBlockNumber(); // test RPC
    status("🟢 Connecté à Ethereum Mainnet");

    contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, provider);
  } catch (e) {
    console.error(e);
    status("🔴 Erreur connexion RPC", false);
    return;
  }

  const tbody = document.getElementById("tbody");
  if (!tbody) return;

  tbody.innerHTML = "";

  const readFns = ABI.filter(
    (f: any) =>
      f.type === "function" &&
      f.name &&
      (f.stateMutability === "view" || f.stateMutability === "pure") &&
      f.inputs.length === 0
  );

  for (const fn of readFns) {
    const fnName = fn.name ?? "unknown"; // ✅ Force string
    const tr = document.createElement("tr");
    const tdName = document.createElement("td");
    const tdRes = document.createElement("td");
    const tdAct = document.createElement("td");
    const btn = document.createElement("button");

    tdName.textContent = fnName; // ✅ corrigé
    tdRes.textContent = "⏳";
    btn.textContent = "↻";

    const run = async () => {
      try {
        tdRes.textContent = "⏳";
        const res = await (contract as any)[fnName](); // ✅ corrigé
        tdRes.textContent = format(res);
      } catch (e) {
        console.error(fnName, e);
        tdRes.textContent = "❌ Erreur";
      }
    };

    btn.onclick = run;

    tdAct.appendChild(btn);
    tr.append(tdName, tdRes, tdAct);
    tbody.appendChild(tr);

    await run(); // auto-load
  }

  document.getElementById("reload")?.addEventListener("click", () => load(root));
}

/* ================= INIT ================= */
const root = document.getElementById("root");
if (!root) {
  document.body.innerHTML = "❌ Root introuvable";
} else {
  load(root);
}
