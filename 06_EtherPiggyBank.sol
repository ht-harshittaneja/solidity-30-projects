// Let's make a digital piggy bank! Users can deposit and withdraw Ether (the cryptocurrency). 
// You'll learn how to manage balances (using `address` to identify users) and track who sent Ether (using `msg.sender`). 
// It's like a simple bank account on the blockchain, demonstrating how to handle Ether and user addresses.

// # Concepts You'll Master
// 1. msg.sender
// 2. address
// 3. Ether balance
// 4. Deposits and withdrawals

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract EtherPiggyBank {
    mapping(address => uint) balances;

    function contractBalance() public view returns(uint) {
    return address(this).balance;
    }

    function getBalance() public view returns(uint) {
    return balances[msg.sender];
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value;
    } 

    function withdraw(uint _amount) public{ //here _amount is in wei
        require(balances[msg.sender] >= _amount , "Insuficient Balance");
        balances[msg.sender]-=_amount;
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
    }
}