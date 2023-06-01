const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Coin Contract', function () {
  let coin;
  let owner;
  let liquid;
  let ico;
  let stake;
  let market;
  let emergency;
  let team;
  let teamRewardWallet;

  beforeEach(async function () {
    [owner, liquid, ico, stake, market, emergency,team] = await ethers.getSigners();
    const Coin = await ethers.getContractFactory('Coin');

    coin = await Coin.deploy(liquid.address,ico.address,stake.address,team.address,market.address,emergency.address);
    await coin.deployed();

    console.log("coin deployed at ==>", coin.address);
  });

  it('should have the correct initial supply', async function () {
    const initialSupply = await coin.initialSupply();
    expect(initialSupply).to.equal(ethers.utils.parseEther('1000000000'));
  });

  it('should transfer the ICO sale tokens to the ICO wallet', async function () {
    let icoBalance = await coin.balanceOf(ico.address);
    let stakeBalance = await coin.balanceOf(stake.address);
    let liqBalance = await coin.balanceOf(liquid.address);
    let emergBalance = await coin.balanceOf(emergency.address);
    
    expect(icoBalance).to.equal(ethers.utils.parseEther('100000000'));
    expect(stakeBalance).to.equal(ethers.utils.parseEther('450000000'));
    expect(liqBalance).to.equal(ethers.utils.parseEther('100000000'));
    expect(emergBalance).to.equal(ethers.utils.parseEther('150000000'));
  });

  it('should release team reward to the team reward wallet', async function () {
    let dailyReward = await coin.dailyTeamReward();
    await coin.releaseTeamReward();
    const teamRewardBalance = await coin.balanceOf(team.address);

    expect(teamRewardBalance).to.equal(ethers.utils.parseEther("1000000"));
  });

  it('should revert if fundis locked', async function () {
    await coin.releaseTeamReward();
    await expect(coin.releaseTeamReward()).to.be.revertedWith('Team reward is locked');

   
  });

  it('should release marketing fund to the marketing budget wallet', async function () {
    const fundAmount = ethers.utils.parseEther('10000000');

    await coin.releaseMarketingFund(fundAmount);
    const marketingBudgetBalance = await coin.balanceOf(market.address);

    expect(marketingBudgetBalance).to.equal(fundAmount);
  });

  it('should release emergency fund to the liquidity wallet', async function () {
    const fundAmount = ethers.utils.parseEther('50000000');
    const liquidityAmount = ethers.utils.parseEther('100000000');

    let liquidityTotalBalance = ethers.utils.parseEther("150000000");

    await coin.releaseEmergencyFund(fundAmount);
    const liquidityBalance = await coin.balanceOf(liquid.address);

    expect(liquidityBalance).to.equal(liquidityTotalBalance);
  });
});
