const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EvanCoin", function () {
  let EvanCoin, evanCoin, owner, addr1, addr2;

  beforeEach(async function () {
    EvanCoin = await ethers.getContractFactory("EvanCoin");
    [owner, addr1, addr2] = await ethers.getSigners();
    evanCoin = await EvanCoin.deploy();
    await evanCoin.deployed();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await evanCoin.owner()).to.equal(owner.address);
    });

    it("Should assign the total supply to the owner", async function () {
      const ownerBalance = await evanCoin.balanceOf(owner.address);
      expect(await evanCoin.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      // Transfer 50 tokens from owner to addr1
      await evanCoin.transfer(addr1.address, 50);
      expect(await evanCoin.balanceOf(addr1.address)).to.equal(50);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const initialOwnerBalance = await evanCoin.balanceOf(owner.address);
      await expect(
        evanCoin.connect(addr1).transfer(owner.address, 1)
      ).to.be.revertedWith("ERC20: transfer amount exceeds balance");
    });
  });
}); 