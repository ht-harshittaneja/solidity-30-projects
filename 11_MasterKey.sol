// Build a secure Vault contract that only the owner (master key holder) can control. 
// You'll split your logic into two parts: a reusable 'Ownable' base contract and a 'VaultMaster' contract that inherits from it. 
// Only the owner can withdraw funds or transfer ownership. This shows how to use Solidity's inheritance model to write clean, reusable access control patterns — just like in real-world production contracts. 
// It's like building a secure digital safe where only the master key holder can access or delegate control.

// # Concepts you will master
// 1. Ownable pattern
// 2. inheritance
// 3. robust access control

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract Ownable {
    address internal  owner ;
    constructor () {
        owner = msg.sender;
    }

     modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

contract VaultMaster is Ownable {

    function deposit() payable public {
    } 

    function withdraw(uint _amount) public onlyOwner{
        require(address(this).balance >= _amount , "Insuficient Balance");
        require(_amount > 0 ,"AMOUNT SHOULD BE MORE THAN 0 WEI ");

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function transfer(uint _amount , address _adr) public onlyOwner{
        require(_amount > 0 ,"AMOUNT SHOULD BE MORE THAN 0 WEI ");
        require(address(this).balance >= _amount , "Insuficient Balance");
        require(_adr != address(0), "INVALID ADDRESS");

        (bool success, ) = payable(_adr).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function balance() public view returns(uint){
        return address(this).balance ;
    }

    function changeOwnership(address _adr) public onlyOwner{
        require(_adr != address(0), "INVALID ADDRESS");
        owner = _adr ;
    }
}