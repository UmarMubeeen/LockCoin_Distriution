// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Coin is ERC20, Ownable {
    uint256 public initialSupply;
    uint256 public icoSale;
    uint256 public stakingReward;
    uint256 public teamReward;
    uint256 public marketingBudget;
    uint256 public liquidityProvision;
    uint256 public emergencyFund;

    address public teamReward_wallet;
    address public stakingReward_wallet;
    address public ico_wallet;
    address public marketingBudget_wallet;
    address public liquidity_wallet;
    address public emergencyFund_wallet;

    uint256 public constant teamReward_ReleasePeriod = 1 days;
    uint256 public teamReward_LastRelease;
    uint256 public constant dailyTeamReward = 1000000 * 10 ** 18; // 1% of total team reward
    uint256 public constant emergencyFund_ReleasePeriod = 2 days;
    uint256 public emergencyFund_LastRelease;
    uint256 public constant dailyStakingReward = 4500000 * 10 ** 18; // 1% of total staking reward
    uint256 public constant stakingReward_ReleasePeriod = 1 days;
    uint256 public stakingReward_LastRelease;

    event TeamRewardReleased(address indexed recipient, uint256 amount);
    event MarketingFundReleased(address indexed recipient, uint256 amount);
    event EmergencyFundReleased(address indexed recipient, uint256 amount);
    event ICOSaleUpdated(uint256 amount);

    constructor(
        address _liquidity_wallet,
        address _ico_wallet,
        address _stakingReward_wallet,
        address _teamReward_wallet,
        address _marketingBudget_wallet,
        address _emergencyFund_wallet
    ) ERC20("Coin", "C-20") {
        liquidity_wallet = _liquidity_wallet;
        ico_wallet = _ico_wallet;
        stakingReward_wallet = _stakingReward_wallet;
        teamReward_wallet = _teamReward_wallet;
        marketingBudget_wallet = _marketingBudget_wallet;
        emergencyFund_wallet = _emergencyFund_wallet;

        SetCoinDistribution();
        _mint(address(this), initialSupply);

        _transfer(address(this),ico_wallet, icoSale); //// Allocate ICO
        _transfer(address(this),stakingReward_wallet, stakingReward); ///  Allocate staking reward
        _transfer(address(this),liquidity_wallet, liquidityProvision); //Allocate liquidity
        _transfer(address(this),emergencyFund_wallet, emergencyFund); ////Allocate emergency fund
    }

    function releaseTeamReward() external onlyOwner {
        require(teamReward_wallet != address(0), "Invalid address");
        require(
            (block.timestamp - teamReward_LastRelease) >=
                teamReward_ReleasePeriod,
            "Team reward is locked"
        );
        require(
            dailyTeamReward <= teamReward,
            "Insufficient balance for team reward"
        );

        teamReward -= dailyTeamReward;
        teamReward_LastRelease = block.timestamp;
        _transfer(address(this),teamReward_wallet, dailyTeamReward);

        emit TeamRewardReleased(teamReward_wallet, dailyTeamReward);
    }

    function releaseMarketingFund(uint256 fundAmount) external onlyOwner() {
        require(fundAmount > 0, "Fund amount must be greater than zero");
        require(
            fundAmount <= marketingBudget,
            "Insufficient balance for marketing fund"
        );

        marketingBudget -= fundAmount;
        _transfer(address(this),marketingBudget_wallet, fundAmount);

        emit MarketingFundReleased(marketingBudget_wallet, fundAmount);
    }

    function releaseEmergencyFund(uint256 fundAmount) external onlyOwner(){
        require(fundAmount > 0, "Fund amount must be greater than zero");
        require(
            (block.timestamp - emergencyFund_LastRelease) >=
                emergencyFund_ReleasePeriod,
            "Emergency fund is locked"
        );
        require(
            fundAmount <= balanceOf(emergencyFund_wallet),
            "Insufficient balance for emergency fund"
        );

        emergencyFund -= fundAmount;
        emergencyFund_LastRelease = block.timestamp;
        _transfer(emergencyFund_wallet, liquidity_wallet, fundAmount);

        emit EmergencyFundReleased(liquidity_wallet, fundAmount);
    }

    function updateICOsale(uint256 amount) public  {
        require(amount > 0, "amount must be greater than zero");
        icoSale -= amount;

        emit ICOSaleUpdated(icoSale);
    }

    function getIcoBalance() public view returns (uint256) {
        return icoSale;
    }

    function SetCoinDistribution() private {
        initialSupply = 1000000000 * 10**18; // 1 billion total supply
        icoSale = 100000000 * 10**18; // 10% lock for ICO
        stakingReward = 450000000 *10**18; // 45% for staking reward
        teamReward = 100000000 * 10**18; // 10% for team reward
        marketingBudget = 100000000 *10**18; //10% marketing budget
        liquidityProvision = 100000000 *10**18; //10% liquidity provision
        emergencyFund = 150000000 * 10**18; //15% emergency fund
    }
}
