 
const hre = require("hardhat");
 
async function main() {  
  const [deployer] = await ethers.getSigners();  
 
  console.log(`Deployer Address: ${deployer.address}`);

  const Controller = await hre.ethers.getContractFactory("BulkEthRegistrarController");
  
  console.log(`Deploying...`);

  const controller = await Controller.deploy();  

  console.log(`Deployed. Getting deployed contract...`);

  await controller.deployed();  

  console.log(`Deployed Controller Address: ${controller.address}`);

}
 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
