// Build a multi-currency digital tip jar! Users can send Ether directly or simulate tips in foreign currencies like USD or EUR. 
// You'll learn how to manage currency conversion, handle Ether payments using `payable` and `msg.value`, and keep track of individual contributions.
// Think of it like an advanced version of a 'Buy Me a Coffee' button — but smarter, more global, and Solidity-powered.

// # Concepts You'll Master
// 1. conversion
// 2. denominations
// 3. payable

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract TipJar{
    address owner ;
    mapping(address => mapping(string => uint)) public contributions;
    mapping(string => uint256) public tips;
    uint public usdToEth;
    uint public eurToEth;

    constructor (uint _usdToEth , uint _eurToEth){
        usdToEth = _usdToEth;
        eurToEth = _eurToEth;
        owner = msg.sender;
    }

    function tipETHr() payable public{
        require(msg.value>0 ,"TIP MUST BE GREATER THAN 0");
        tips["ETH"] += msg.value;
        contributions[msg.sender]["ETH"] += msg.value;
    }

    function tipUSD (uint _amount) public {
        require(_amount>0 ,"TIP MUST BE GREATER THAN 0");
        tips["USD"] += _amount;
        tips["ETH"] += _amount*usdToEth;
        contributions[msg.sender]["USD"] += _amount;
    }

    function tipEUR (uint _amount) public {
        require(_amount>0 ,"TIP MUST BE GREATER THAN 0");
        tips["EUR"] += _amount;
        tips["ETH"] += _amount*eurToEth;
        contributions[msg.sender]["EUR"] += _amount;
    }

    function setConversionRates(uint usdRate, uint eurRate) public {
        require(msg.sender == owner, "NOT A OWNER");
        usdToEth = usdRate;
        eurToEth = eurRate;
    }

    function getUserTip(address user, string memory currency) public view returns (uint) {
        return contributions[user][currency];
    }
}