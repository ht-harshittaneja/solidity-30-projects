// Build a simple IOU contract for a private group of friends. Each user can deposit ETH, track personal balances, log who owes who, and settle debts — all on-chain. 
// You’ll learn how to accept real Ether using `payable`, transfer funds between addresses, and use nested mappings to represent relationships like 'Alice owes Bob'.
// This contract mirrors real-world borrowing and lending, and teaches you how to model those interactions in Solidity.

// # Concepts You'll Master
// 1. address
// 2. token transfer
// 3. payable for gas
// 4. validation (require)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract SimpleIOU{
    // All balances are stored in wei.
    mapping(address => mapping(address => uint)) debts ;

    function lend(address _adr) payable public{
        require(_adr != address(0), "Invalid address");
        require(msg.value>0 ,"lending should be more than 0");
        require(_adr != msg.sender, "Cannot lend to yourself");
        debts[_adr][msg.sender] += msg.value ;
        netDebts(_adr);

        (bool success, ) = payable(_adr).call{value: msg.value}("");
        require(success, "Transfer failed");
    }

    function netDebts(address _adr) private{
        if(debts[msg.sender][_adr]!=0){
        if(debts[msg.sender][_adr] <= debts[_adr][msg.sender]){
            debts[_adr][msg.sender] -= debts[msg.sender][_adr];
            debts[msg.sender][_adr] = 0 ;
        }
        else{
            debts[msg.sender][_adr] -=debts[_adr][msg.sender];
            debts[_adr][msg.sender] = 0;
        }
        }
    }

    function myOwing(address _adr) public view returns(uint) {
        return debts[msg.sender][_adr];
    }

    function clearDebt(address _adr) payable public{
        require(_adr != address(0), "Invalid address");
        require(debts[msg.sender][_adr] !=0 , "YOU Don't Owe this address");
        require(msg.value <= debts[msg.sender][_adr],"Repaying more than owed");
        require(msg.value > 0, "Amount must be greater than zero");

        debts[msg.sender][_adr] -= msg.value ;
        (bool success, ) = payable(_adr).call{value: msg.value}("");
        require(success, "Transfer failed");
    }
}