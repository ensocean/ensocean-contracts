
require("dotenv").config(); 
require("@nomicfoundation/hardhat-toolbox"); 
require("@nomiclabs/hardhat-etherscan");

 
const {ALCHEMY_API_KEY, DEPLOYER_PRIVATE_KEY, ETHERSCAN_API_KEY} = process.env;
 
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.12"
      }
    ]
  },
  etherscan: {
    apiKey: {
      mainnet: ETHERSCAN_API_KEY,
      goerli: ETHERSCAN_API_KEY
    }
  },
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