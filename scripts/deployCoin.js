
const {ethers} = require("hardhat");

async function main() {
  const [owner, liquid, ico, stake, market, emergency,team] = await ethers.getSigners();
  const COIN = await ethers.getContractFactory("Coin");
  const coin = await COIN.deploy(liquid.address,ico.address,stake.address,team.address,market.address,emergency.address);

  await coin.deployed();
  console.log("coin deployed at ==>", coin.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
