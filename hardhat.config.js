import "@nomicfoundation/hardhat-ethers";

/** @type import('hardhat/config').HardhatUserConfig */
export default {
  solidity: "0.8.20",

  paths: {
    sources: "./contracts"
  },

  networks: {
    hardhat: {
      type: "edr-simulated"
    }
  }
};
