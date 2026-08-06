// Build a secure digital vault where users can deposit and withdraw tokenized gold (or any valuable asset), ensuring it's protected from reentrancy attacks. 
// Imagine you're creating a decentralized version of Fort Knox — users lock up tokenized gold, and can later withdraw it. 
// But just like a real vault, this contract must prevent attackers from repeatedly triggering the withdrawal logic before the balance updates. 
// You'll implement the `nonReentrant` modifier to block reentry attempts, and follow Solidity security best practices to lock down your contract. 
// This project shows how a seemingly simple withdrawal function can become a vulnerability — and how to defend it properly.

// # Concepts you will master
// 1. Reentrancy attacks
// 2. nonReentrant modifier
// 3. security best practices

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract FortKnox {
    address public owner;
    uint256 public ethToGoldRate;
    mapping(address => uint256) public goldBalance;

    constructor(uint256 _ethToGoldRate) {
        require(_ethToGoldRate > 0, "Invalid rate");
        owner = msg.sender ;
        ethToGoldRate = _ethToGoldRate ; 
    }

    modifier onlyOwner() {
        require(owner == msg.sender ,"NOT A VALID OWNER");
        _;
    }

    bool private locked;
    modifier nonReentrant() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    function deposit() payable external {
        require(msg.value >0 , "VALUE MUST BE GREATER THAN 0");
        uint256 gold = (msg.value * ethToGoldRate) / 1 ether;
        goldBalance[msg.sender] += gold;
    }

    function withdraw(uint256 goldTokens) external nonReentrant {
        require(goldBalance[msg.sender]>=goldTokens ,"INSUFFICIENT TOKENS");
        goldBalance[msg.sender] -= goldTokens;
        uint256 ethAmount = (goldTokens * 1 ether)/ethToGoldRate;
        require(address(this).balance >= ethAmount ,"INSUFFICIENT CONTRACT BALANCE");
        (bool success , ) = payable(msg.sender).call{value : ethAmount}("");
        require(success ,"TRANSACTION FAILED");
    }

    function checkBalance() public view returns (uint256) {
        return goldBalance[msg.sender];
    }

    function changeRate(uint256 _newEthToGoldRate) external onlyOwner{
        require(_newEthToGoldRate > 0, "Invalid rate");
        ethToGoldRate = _newEthToGoldRate ;
    }

    function depositOwner() payable external onlyOwner {
    }

    function withdrawOwner(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount ,"INSUFFICIENT CONTRACT BALANCE");
        (bool success , ) = payable(msg.sender).call{value : _amount}("");
        require(success ,"TRANSACTION FAILED");
    }
}