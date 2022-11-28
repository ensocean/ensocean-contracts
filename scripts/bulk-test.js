 
const hre = require("hardhat");
const delay = ms => new Promise(resolve => setTimeout(resolve, ms)) 
const BASE_CONTROLLER = process.env.BASE_CONTROLLER; 
const CONTROLLER_ADDRESS = process.env.CONTROLLER_ADDRESS; 
const OWNER = process.env.OWNER;
const SECRET = process.env.SECRET;
const RESOLVER = process.env.RESOLVER;
const BULK_QUERY = [{name: "loremipsumdolor23", duration: 41556952}, {name: "loremipsumdolor24", duration: 31556952}];
 
async function main() {  
 
  const [deployer] = await ethers.getSigners();  

  console.log(`Deployer Address: ${deployer.address}`);
 
  const controller = await hre.ethers.getContractAt("BulkEthRegistrarController", CONTROLLER_ADDRESS);
      
  console.log("Is Available...");
  const available = await controller.connect(deployer).bulkAvailable(BASE_CONTROLLER, BULK_QUERY.map(t=> t.name));
  console.table(available);

  console.log("Getting Prices...");
  const prices = await controller.connect(deployer).bulkRentPrice(BASE_CONTROLLER, BULK_QUERY);
  console.table(prices[0].map(t=> {
    return {name: t.name, available: t.available, duration: t.duration, price: t.price} 
  }));
  const totalPrice = prices[1];
  console.log("Total Price: "+ totalPrice);

  console.log("Commiting...");
  const commitTx = await controller.connect(deployer).bulkCommitWithConfig(BASE_CONTROLLER, OWNER, BULK_QUERY, SECRET, RESOLVER, OWNER);
  await commitTx.wait();
  console.log("Commit transaction completed. Hash: "+ commitTx.hash);

  console.log("Wait for one minute...")
  await delay(60000);

  console.log("Registering...");
  const registerTx = await controller.connect(deployer).bulkRegisterWithConfig(BASE_CONTROLLER, OWNER, BULK_QUERY, SECRET, RESOLVER, OWNER, { value: totalPrice });
  await registerTx.wait();
  console.log("Register transaction completed. Hash: "+ registerTx.hash);

  console.log("Renewing...");
  const renewTx = await controller.connect(deployer).bulkRenew(BASE_CONTROLLER, BULK_QUERY, { value: totalPrice });
  await renewTx.wait();
  console.log("Renew transaction completed. Hash: "+ renewTx.hash);
   
  console.log("All done.");
}
 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
