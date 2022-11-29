require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai"); 

const BASE_CONTROLLER = process.env.BASE_CONTROLLER;
const initialAmount = ethers.utils.parseEther("100");
const wrongAmount = ethers.utils.parseEther("999");
const initialTokenAmount = ethers.utils.parseEther("548");
 
describe("Controller", function () { 

  async function deployController() {
    const [owner, other, fake] = await ethers.getSigners();
 
    const Controller = await ethers.getContractFactory("BulkEthRegistrarController");
    const controller = await Controller.deploy();
 
    const Token = await ethers.getContractFactory("SampleToken");
    const token = await Token.deploy();
 
    await token.mint(controller.address, initialTokenAmount);

    return { controller, owner, other, token, fake };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { controller, owner } = await deployController();

      expect(await controller.owner()).to.equal(owner.address);
    }); 
  });
 
  describe("Withdraws", function () {

    it("Should withdraw to the right owner", async function () {
      const { controller, owner } = await deployController();

      await expect(controller.withdraw(owner.address)).not.to.be.reverted;
    }); 

    it("Should not withdraw to the other account", async function () {
      const { controller, other } = await deployController();

      await expect(controller.connect(other).withdraw(other.address)).to.be.reverted;
    }); 

    it("Should withdrawOf to the right owner", async function () {
      const { controller, owner, token } = await deployController();

      await expect(controller.withdrawOf(owner.address, token.address)).not.to.be.reverted;
    }); 

    it("Should not withdrawOf to the other account", async function () {
      const { controller, other, token } = await deployController();

      await expect(controller.connect(other).withdrawOf(other.address, token.address)).to.be.reverted;
    }); 
  }); 
  
  describe("Fee", function () {

    it("Should set fee by the owner", async function () {
      const { controller } = await deployController();

      await expect(controller.setFeeRatio(3)).not.to.be.reverted;
    });  

    it("Should not set fee by the other account", async function () {
      const { controller, other } = await deployController();

      await expect(controller.connect(other).setFeeRatio(0)).to.be.reverted;
    }); 

    it("Should fee equal to new fee", async function () {
      const { controller, fake } = await deployController();

      await controller.setFeeRatio(4);
      expect(await controller.getFeeRatio()).to.equal(4);
    }); 
  }); 
   
});
