// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Coin.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract ICO is Ownable {
    uint public startSaleTime;
    uint public closeSaleTime;
    uint public constant price = 0.1 * 10 ** 18; // $0.1 in wei;
    Coin public token;

    event TokenPurchase(address indexed buyer, uint tokenAmount, uint etherAmount);
    event EtherWithdrawal(address indexed owner, uint amount);

    constructor(uint _startSaleTime, uint _closeSaleTime, Coin _Token) {
        startSaleTime = _startSaleTime;
        closeSaleTime = _closeSaleTime;

        require(
            _startSaleTime > 0,
            "starting sale time sale cannot be equal to zero"
        );
        require(
            _closeSaleTime != _startSaleTime,
            "starting and ending sale time should not be same"
        );
        require(
            _startSaleTime < _closeSaleTime,
            "starting sale time must be less than ending sale time"
        );

        token = _Token;
    }

    modifier onlyWhileActive() {
        require(
            block.timestamp > startSaleTime && block.timestamp < closeSaleTime,
            "The token Sale must be active"
        );
        _;
    }

    modifier onlyWhenClosed() {
        require(
            block.timestamp > closeSaleTime,
            "The token sale must be closed"
        );
        _;
    }

    function saleActiveStatus() public view returns (bool status) {
        if (
            block.timestamp > startSaleTime && block.timestamp < closeSaleTime
        ) {
            return true;
        }
        if (block.timestamp > closeSaleTime) {
            return false;
        }
    }

    function buyToken(uint tokenAmount) external payable onlyWhileActive {
        address buyer = msg.sender;

        require(buyer != address(0), "buyer cannot be equal to address(0)");
        require(tokenAmount > 0, "Token amount must be greater than zero");
        require(msg.value != 0, "value send cannot be equal to zero");
        require(
            token.allowance(token.ico_wallet(), address(this)) >= tokenAmount,
            "Insufficient allowance"
        );
        require(
            tokenAmount <= token.getIcoBalance(),
            "Insufficient coin Balance"
        );

        uint tokenValue = tokenAmount * price;
        require(msg.value == tokenValue, "insufficient amount to buy token");
        token.updateICOsale(tokenAmount);
        token.transferFrom(token.ico_wallet(), buyer, tokenValue);

        emit TokenPurchase(buyer, tokenAmount, tokenValue);

    }

    function withdrawether() external onlyOwner onlyWhenClosed {
        require(address(this).balance > 0, "Not enough amount to withdraw");
        payable(owner()).transfer(address(this).balance);

        emit EtherWithdrawal(owner(), address(this).balance);

    }

}
