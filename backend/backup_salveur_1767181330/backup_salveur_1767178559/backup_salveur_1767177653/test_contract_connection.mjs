import { omniUtilContract } from './src/index.js';

async function testContractConnection() {
  try {
    const name = await omniUtilContract.name();
    const symbol = await omniUtilContract.symbol();
    console.log(`Contrat connecté avec succès !`);
    console.log(`Nom: ${name}, Symbole: ${symbol}`);
  } catch (error) {
    console.error(`Erreur de connexion au contrat: ${error}`);
  }
}

testContractConnection();
