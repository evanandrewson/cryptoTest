const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy EvanCoin
  const EvanCoin = await hre.ethers.getContractFactory("EvanCoin");
  const evanCoin = await EvanCoin.deploy();
  await evanCoin.deployed();

  console.log("✅ EvanCoin deployed successfully");
  console.log("📜 EvanCoin address:", evanCoin.address);
  console.log("🔍 View on BSCscan: https://testnet.bscscan.com/address/" + evanCoin.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 