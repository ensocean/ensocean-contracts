 
const hre = require("hardhat"); 
const { ENS_REGISTRY_ADDRESS, REVERSE_REGISTER_ADDRESS } = process.env; 

async function main() {  
  const [deployer] = await ethers.getSigners();  
 
  console.log(`Deployer Address: ${deployer.address}`);

  const ReverseLookup = await hre.ethers.getContractFactory("ReverseLookup");
  
  console.log(`Deploying...`);

  console.log(REVERSE_REGISTER_ADDRESS)

  const reverseLookup = await ReverseLookup.deploy(ENS_REGISTRY_ADDRESS, REVERSE_REGISTER_ADDRESS);  

  console.log(`Deployed. Getting deployed contract...`);

  await reverseLookup.deployed();  

  console.log(`Deployed ReverseLookup Address: ${reverseLookup.address}`);

}
 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
