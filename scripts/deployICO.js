// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const endTime = currentTimestampInSeconds + 6000;

  const ICO = await hre.ethers.getContractFactory("ICO");
  const ico = await ICO.deploy(currentTimestampInSeconds,endTime, "0x5FbDB2315678afecb367f032d93F642f64180aa3");

  await ico.deployed();
  console.log("ICO deployed at ==>", ico.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
