require("dotenv").config();

require("@nomicfoundation/hardhat-toolbox"); 
  
const {ALCHEMY_API_KEY, DEPLOYER_PRIVATE_KEY} = process.env;

module.exports = {
  solidity: "0.8.12",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [DEPLOYER_PRIVATE_KEY]
    }
  }
};