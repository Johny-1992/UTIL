const tx = {
  user: "USER_001",
  rewardUTIL: 25,
  txHash: "0xSIMULATED_OMNIUTIL_TX",
  block: Math.floor(Math.random() * 1000000),
  timestamp: new Date().toISOString()
};

console.log("📜 SMART CONTRACT OMNIUTIL EXECUTÉ");
console.log(tx);
