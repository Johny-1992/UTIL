// Omniutil – Simulation Droit d'Auteur & Soutien Infrastructure

const OWNER_WALLET = "OWNER_WALLET";
const INFRA_WALLET = "INFRA_WALLET";

let balances = {
  OWNER_WALLET: 0,
  INFRA_WALLET: 0,
  USER_001: 0,
  USER_002: 0,
};

// Helpers
function log(title, data) {
  console.log("\n" + title);
  console.log(JSON.stringify(data, null, 2));
}

// 1️⃣ Mint UTIL
function mintUTIL(user, amount) {
  const authorFee = amount * 0.05;
  const infraFee = amount * 0.05;
  const net = amount - authorFee - infraFee;

  balances[OWNER_WALLET] += authorFee;
  balances[INFRA_WALLET] += infraFee;
  balances[user] += net;

  log("📜 MINT UTIL", {
    user,
    amount,
    authorFee,
    infraFee,
    receivedByUser: net,
  });
}

// 2️⃣ Exchange UTIL → USDT
function exchangeUTIL(user, amount) {
  const authorFee = amount * 0.05;
  const infraFee = amount * 0.05;
  const net = amount - authorFee - infraFee;

  balances[OWNER_WALLET] += authorFee;
  balances[INFRA_WALLET] += infraFee;
  balances[user] -= amount;

  log("💱 EXCHANGE UTIL → USDT", {
    user,
    amountUTIL: amount,
    authorFee,
    infraFee,
    netConverted: net,
  });
}

// 3️⃣ Transfer UTIL
function transferUTIL(from, to, amount) {
  const authorFee = amount * 0.05;
  const infraFee = amount * 0.05;
  const net = amount - authorFee - infraFee;

  balances[from] -= amount;
  balances[OWNER_WALLET] += authorFee;
  balances[INFRA_WALLET] += infraFee;
  balances[to] += net;

  log("🔁 TRANSFERT UTIL", {
    from,
    to,
    amount,
    authorFee,
    infraFee,
    receivedByRecipient: net,
  });
}

// 🚀 SIMULATION
console.log("🚀 SIMULATION DROIT D'AUTEUR & SOUTIEN INFRA — OMNIUTIL");

// Mint
mintUTIL("USER_001", 100);

// Exchange
exchangeUTIL("USER_001", 20);

// Transfer
transferUTIL("USER_001", "USER_002", 10);

// Final balances
log("📊 SOLDES FINAUX", balances);

console.log("\n✅ SIMULATION TERMINÉE");
