const hre = require("hardhat");

async function main() {
  // We get the contract to deploy
  const Pay = await hre.ethers.getContractFactory("Pay");
  const pay = await Pay.deploy();
  console.log("Deploying");
  await pay.waitForDeployment();

  console.log("Pay deployed to:", pay.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
