// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Coin.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    struct Stake {
        uint256 amount;
        uint256 startTime;
    }

    Coin private token;
    uint256 private totalStaked;
    uint256 private totalRewards;
    address[] stackHolders;

    mapping(address => Stake) private stakes;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardWithdrawn(address indexed user, uint256 amount);

    constructor(Coin _tokenAddress) {
        token = _tokenAddress;
    }

    function stakeCoins(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(
            token.allowance(msg.sender, address(this)) >= _amount,
            "Insufficient allowance"
        );

        if (stakes[msg.sender].amount == 0) {
            stakes[msg.sender].startTime = block.timestamp;
        }
        stackHolders.push(msg.sender);
        token.transferFrom(msg.sender, address(this), _amount);

        stakes[msg.sender].amount += _amount;
        totalStaked += _amount;

        emit Staked(msg.sender, _amount);
    }

    function unstakeCoins() external {
        require(stakes[msg.sender].amount > 0, "No stake found");

        uint256 stakedAmount = stakes[msg.sender].amount;

        removeStakeHolder(msg.sender);
        delete stakes[msg.sender];
        totalStaked -= stakedAmount;

        token.transfer(msg.sender, stakedAmount);

        emit Unstaked(msg.sender, stakedAmount);
    }

    function payReward() external onlyOwner{
        uint256 rewardLastRelease = token.stakingReward_LastRelease();
        uint256 rewardReleasePeriod = token.stakingReward_ReleasePeriod();
        uint256 rewards = token.dailyStakingReward();

        require(
            (block.timestamp - rewardLastRelease) >= rewardReleasePeriod,
            "staking reward is locked"
        );
        require(
            token.allowance(token.stakingReward_wallet(), address(this)) >=
                rewards * stackHolders.length,
            "Insufficient allowance"
        );

        for (uint256 i = 0; i < stackHolders.length; i++) {
            token.transferFrom(
                token.stakingReward_wallet(),
                stackHolders[i],
                rewards
            );
            totalRewards += rewards;
        }

        emit RewardWithdrawn(msg.sender, rewards);
    }

    function getStakedAmount(address _user) external view returns (uint256) {
        return stakes[_user].amount;
    }

    function getTotalStaked() external view returns (uint256) {
        return totalStaked;
    }

    function getTotalRewards() external view returns (uint256) {
        return totalRewards;
    }

    function removeStakeHolder(address addressToRemove) internal {
        for (uint256 i = 0; i < stackHolders.length; i++) {
            if (stackHolders[i] == addressToRemove) {
                stackHolders[i] = stackHolders[stackHolders.length - 1];
                stackHolders.pop();
                break;
            }
        }
    }
}
