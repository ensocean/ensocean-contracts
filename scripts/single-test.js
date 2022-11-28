 
const hre = require("hardhat");

const delay = ms => new Promise(resolve => setTimeout(resolve, ms)) 
const CONTROLLER_ADDRESS = process.env.CONTROLLER_ADDRESS; 
const OWNER = process.env.OWNER;
const SECRET = process.env.SECRET;
const RESOLVER = process.env.RESOLVER;
const NAME = "loremipsum4";
const DURATION = 31556952;

async function main() {  
 
  const [deployer] = await ethers.getSigners();  

  console.log(`Deployer Address: ${deployer.address}`);
 
  const controller = await hre.ethers.getContractAt("BulkEthRegistrarController", CONTROLLER_ADDRESS);
      
  console.log("Is Available...");
  const available = await controller.connect(deployer).available(NAME);
  console.log("Available: "+ available);

  console.log("Getting Price...");
  const price = await controller.connect(deployer).rentPrice(NAME, DURATION);
  console.log("Price: "+ price);
 
  console.log("Making commitment...");
  const commitment = await controller.connect(deployer).makeCommitmentWithConfig(NAME, OWNER, SECRET, RESOLVER, OWNER);
  console.log("Commitment: "+ commitment);
 
  console.log("Sending commit...");
  const commitTx = await controller.connect(deployer).commit(commitment);
  await commitTx.wait();
  console.log("Commit transaction completed. Hash: "+ commitTx.hash);

  console.log("Wait for one minute...")
  await delay(60000);
   
  console.log("Sending register...");
  const registerTx = await controller.connect(deployer).registerWithConfig(NAME, OWNER, DURATION, SECRET, RESOLVER, OWNER, { value: price })
  await registerTx.wait();
  console.log("Register transaction completed. Hash: "+ registerTx.hash);

  console.log("Sending renew...");
  const renewTx = await controller.connect(deployer).renew(NAME, DURATION, { value: price })
  await renewTx.wait();
  console.log("Renew transaction completed. Hash: "+ renewTx.hash);

  console.log("All done.");
}
 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
