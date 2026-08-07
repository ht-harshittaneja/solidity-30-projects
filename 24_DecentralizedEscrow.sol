// Build a secure system for holding funds until conditions are met. 
// You'll learn how to manage payments and handle disputes. 
// It's like a digital middleman for secure transactions, demonstrating secure conditional payments.

// # Concepts you will master
// 1. Escrow service
// 2. conditional payments
// 3. dispute resolution

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract DecentralizedEscrow{
    address public buyer;
    address public seller;
    address public arbiter;
    uint256 public amount;
    bool public buyerApproved;
    bool public sellerApproved;
    bool public disputed;

    constructor(address _arbiter ,uint256 _amount) {
        require(_arbiter != address(0));
        seller = msg.sender;
        arbiter = _arbiter;
        amount = _amount;
    }

    function buy() payable external {
        require(buyer == address(0), "Buyer already exists");
        buyer = msg.sender;
        require(msg.value == amount ,"VALUE SHOULD BE EQUAL TO AMOUNT");
    }

    function approve() public {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        if (msg.sender == buyer) buyerApproved = true;
        if (msg.sender == seller) sellerApproved = true;
        if (buyerApproved && sellerApproved) releaseFunds();
    }

    function raiseDispute() public {
        require(msg.sender == buyer || msg.sender == seller, "Not allowed");
        disputed = true;
    }

    function resolveDispute(address _winner) public {
        require(msg.sender == arbiter, "Only arbiter");
        require(disputed, "No dispute raised");
        disputed = false;

        (bool success , ) =payable(_winner).call{value: address(this).balance}("");
        require(success ,"TRANSACTION FAILED");
    }

    function releaseFunds() internal {
        require(!disputed, "Dispute active");
        
        (bool success , ) = payable(seller).call{value:address(this).balance}("");
        require(success ,"TRANSACTION FAILED");
    }

    function getDetails() public view returns (address, address, uint, bool) {
        return (buyer, seller, amount, disputed);
    }
}