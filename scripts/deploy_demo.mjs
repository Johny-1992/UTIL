import hre from "hardhat";

async function main() {
  console.log("🚀 Déploiement OmniUtilCore (Hardhat v3 + viem OK)");

  const [walletClient] = await hre.viem.getWalletClients();

  console.log("👤 Déployeur :", walletClient.account.address);

  const contract = await hre.viem.deployContract(
    "OmniUtilCore",
    [
      process.env.TREASURY_ADDRESS,
      process.env.AI_COORDINATOR,
    ],
    { walletClient }
  );

  console.log("✅ Contrat déployé à :", contract.address);
}

main().catch((err) => {
  console.error("❌ Erreur fatale :", err);
  process.exit(1);
});
