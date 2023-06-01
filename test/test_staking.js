const { expect } = require('chai');
const { ethers } = require('hardhat');

describe("Staking", function () {
  let token;
  let staking;
  let owner;
  let user1;
  let user2;
  let liquid;
  let ico;
  let stake;
  let market;
  let emergency;

  beforeEach(async function () {

    // Get signers from the provider
    [owner, user1, user2, liquid,ico,stake,market,emergency] = await ethers.getSigners();

    const Coin = await ethers.getContractFactory('Coin');

    token = await Coin.deploy(liquid.address,ico.address,stake.address,liquid.address,market.address,emergency.address);
    await token.deployed();

    console.log("coin deployed at ==>", token.address);

    // Deploy the Staking contract
    const staking = await ethers.getContractFactory("Staking");
    stakingContract = await staking.deploy(token.address);
    await stakingContract.deployed();

    const amountTransfer = ethers.utils.parseEther("20");
    await token.connect(emergency).transfer(user1.address, amountTransfer);
    await token.connect(emergency).transfer(user2.address, amountTransfer);

  });

  it("should stake coins", async function () {
    const amount = ethers.utils.parseEther("10");

    await token.connect(user1).approve(stakingContract.address, amount);
    await stakingContract.connect(user1).stakeCoins(amount);

    const user1StakedAmount = await stakingContract.getStakedAmount(user1.address);
    const totalStaked = await stakingContract.getTotalStaked();

    expect(user1StakedAmount).to.equal(amount);
    expect(totalStaked).to.equal(amount);
  });

  it("should unstake coins", async function () {
    const amount = ethers.utils.parseEther("10");

    await token.connect(user1).approve(stakingContract.address, amount);
    await stakingContract.connect(user1).stakeCoins(amount);

    await stakingContract.connect(user1).unstakeCoins();

    const user1StakedAmount = await stakingContract.getStakedAmount(user1.address);
    const totalStaked = await stakingContract.getTotalStaked();

    expect(user1StakedAmount).to.equal(0);
    expect(totalStaked).to.equal(0);
  });

  it("should pay rewards", async function () {
    const amount = ethers.utils.parseEther("10");
    const rewardWallet = owner.address;
    const rewardReleasePeriod = 3600; // 1 hour
    const dailyStakingReward = ethers.utils.parseEther("4500000");

    // await token.connect(owner).setStakingReward(rewardWallet, rewardReleasePeriod, dailyStakingReward);

    await token.connect(user1).approve(stakingContract.address, amount);
    await stakingContract.connect(user1).stakeCoins(amount);

    await token.connect(user2).approve(stakingContract.address, amount);
    await stakingContract.connect(user2).stakeCoins(amount);

    const user1InitialBalance = await token.balanceOf(user1.address);
    const user2InitialBalance = await token.balanceOf(user2.address);

    await ethers.provider.send("evm_increaseTime", [rewardReleasePeriod]); // Fast-forward time to trigger reward payment
    await ethers.provider.send("evm_mine"); // Mine a new block

    await token.connect(stake).approve(stakingContract.address, token.balanceOf(stake.address));
    await stakingContract.payReward();

    const user1FinalBalance = await token.balanceOf(user1.address);
    const user2FinalBalance = await token.balanceOf(user2.address);

    const expectedReward = dailyStakingReward; // 2 users staked
    const rewardWithdrawn = user1FinalBalance.sub(user1InitialBalance);
    const rewardWithdrawn2 = user2FinalBalance.sub(user2InitialBalance);

    expect(rewardWithdrawn).to.equal(expectedReward);
    expect(rewardWithdrawn2).to.equal(expectedReward); // User2 did not trigger reward payment
  });
});
