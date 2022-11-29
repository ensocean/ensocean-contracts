 
const hre = require("hardhat");
const delay = ms => new Promise(resolve => setTimeout(resolve, ms)) 
const BASE_CONTROLLER = process.env.BASE_CONTROLLER; 
const CONTROLLER_ADDRESS = process.env.CONTROLLER_ADDRESS; 
const OWNER = process.env.OWNER;
const SECRET = process.env.SECRET;
const RESOLVER = process.env.RESOLVER;
const BULK_QUERY = [{name: "loremipsumdolor30", duration: 41556952, owner: OWNER, resolver: RESOLVER, addr: OWNER }, {name: "loremipsumdolor31", duration: 31556952, owner: OWNER, resolver: RESOLVER, addr: OWNER }];
 
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
  const totalCost = prices[1];
  const totalCostWithFee = prices[2];
  console.log("TotalCost --> "+ hre.ethers.utils.formatEther(totalCost));
  console.log("TotalCostWithFee --> "+ hre.ethers.utils.formatEther(totalCostWithFee));
  console.log("TotalServiceFee --> "+ hre.ethers.utils.formatEther(totalCostWithFee.sub(totalCost)));

  console.log("Commiting...");
  const commitTx = await controller.connect(deployer).bulkCommit(BASE_CONTROLLER, BULK_QUERY, SECRET);
  await commitTx.wait();
  console.log("Commit transaction completed. Hash: "+ commitTx.hash);

  console.log("Wait for one minute...")
  await delay(60000);

  console.log("Registering...");
  const registerTx = await controller.connect(deployer).bulkRegister(BASE_CONTROLLER, BULK_QUERY, SECRET, { value: totalCostWithFee });
  await registerTx.wait();
  console.log("Register transaction completed. Hash: "+ registerTx.hash);

  console.log("Renewing...");
  const renewTx = await controller.connect(deployer).bulkRenew(BASE_CONTROLLER, BULK_QUERY, { value: totalCostWithFee });
  await renewTx.wait();
  console.log("Renew transaction completed. Hash: "+ renewTx.hash);
  
  console.log("All done.");
}
 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
