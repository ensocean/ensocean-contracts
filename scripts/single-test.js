 
const hre = require("hardhat");

const delay = ms => new Promise(resolve => setTimeout(resolve, ms)) 
const BASE_CONTROLLER = process.env.BASE_CONTROLLER; 
const CONTROLLER_ADDRESS = process.env.CONTROLLER_ADDRESS; 
const OWNER = process.env.OWNER;
const SECRET = process.env.SECRET;
const RESOLVER = process.env.RESOLVER;
const NAME = "loremipsum9";
const DURATION = 31556952;

async function main() {  
 
  const [deployer] = await ethers.getSigners();  

  console.log(`Deployer Address: ${deployer.address}`);
 
  const controller = await hre.ethers.getContractAt("BulkEthRegistrarController", CONTROLLER_ADDRESS);
      
  console.log("Is Available...");
  const available = await controller.connect(deployer).available(BASE_CONTROLLER, NAME);
  console.log("Available: "+ available);

  console.log("Getting Price...");
  const price = await controller.connect(deployer).rentPrice(BASE_CONTROLLER, NAME, DURATION);
   
  console.log("Getting Fee Ratio...");
  const feeRatio = await controller.connect(deployer).getFeeRatio();
  console.log("FeeRatio: "+ feeRatio);

  console.log("Price --> "+ hre.ethers.utils.formatEther(price));
  console.log("Service Cost --> "+ hre.ethers.utils.formatEther(price.div(100).mul(feeRatio)))
  console.log("Total Cost --> "+ hre.ethers.utils.formatEther(price.div(100).mul(feeRatio).add(price)))
 
  console.log("Making commitment...");
  const commitment = await controller.connect(deployer).makeCommitmentWithConfig(BASE_CONTROLLER, NAME, OWNER, SECRET, RESOLVER, OWNER);
  console.log("Commitment: "+ commitment);
 
  console.log("Sending commit...");
  const commitTx = await controller.connect(deployer).commit(BASE_CONTROLLER, commitment);
  await commitTx.wait();
  console.log("Commit transaction completed. Hash: "+ commitTx.hash);

  console.log("Wait for one minute...")
  await delay(60000);
   
  console.log("Sending register...");
  const registerTx = await controller.connect(deployer).registerWithConfig(BASE_CONTROLLER, NAME, OWNER, DURATION, SECRET, RESOLVER, OWNER, { value: price.div(100).mul(feeRatio).add(price) })
  await registerTx.wait();
  console.log("Register transaction completed. Hash: "+ registerTx.hash);

   
  console.log("Sending renew...");
  const renewTx = await controller.connect(deployer).renew(BASE_CONTROLLER, NAME, DURATION, { value: price.div(100).mul(feeRatio).add(price) })
  await renewTx.wait();
  console.log("Renew transaction completed. Hash: "+ renewTx.hash);

  console.log("All done.");
}
 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
