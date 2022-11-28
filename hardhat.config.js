
require("dotenv").config();
require("hardhat-gas-reporter");

require("@nomicfoundation/hardhat-toolbox"); 
 
const {ALCHEMY_API_KEY, DEPLOYER_PRIVATE_KEY} = process.env;

module.exports = {
  solidity: "0.8.12",
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [DEPLOYER_PRIVATE_KEY]
    },
    mainnet: {
      url: `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [DEPLOYER_PRIVATE_KEY]
    }
  }
};