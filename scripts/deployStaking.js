
const {ethers} = require("hardhat");

async function main() {
  const [owner, liquid, ico, stake, market, emergency,team] = await ethers.getSigners();
  const STAKING = await ethers.getContractFactory("Staking");
  const Staking = await STAKING.deploy("0x5FbDB2315678afecb367f032d93F642f64180aa3");

  await Staking.deployed();
  console.log("Staking deployed at ==>", Staking.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
