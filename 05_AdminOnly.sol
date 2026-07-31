// Build a contract that simulates a treasure chest controlled by an owner. 
// The owner can add treasure, approve withdrawals for specific users, and even withdraw treasure themselves. 
// Other users can attempt to withdraw, but only if the owner has given them an allowance and they haven't withdrawn before. 
// The owner can also reset withdrawal statuses and transfer ownership of the treasure chest. 
// This demonstrates how to create a contract with restricted access using a 'modifier' and `msg.sender`, similar to how only an admin can perform certain actions in a game or application.

// # Concepts You'll Master
// 1. modifier
// 2. msg.sender for ownership
// 3. Basic access control

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract AdminOnly{
    address private owner ;
    constructor (){
        owner = msg.sender ;
    }
    mapping(address => bool ) private eligible ;
    uint public treasure = 3000;
    uint public rewardAmount = 25;
    mapping(address => bool ) private withdrawn ;

    modifier onlyOwner() {
        require( msg.sender == owner, "YOU ARE NOT OWNER");
        _;
    }

    modifier onlyTreasurer(){
        require(eligible[msg.sender], "NOT A Treasurer");
        _;
    }

    modifier available(){
        require(treasure >= rewardAmount ,"Treasure is Finished");
        require(!withdrawn[msg.sender] ,"Already Withdrawn ");
        _;
    }

    function isEligible() public onlyTreasurer view returns(bool) {
        return true ;
    }

    function withdrawTreasure() public onlyTreasurer available {
        treasure -= rewardAmount;
        withdrawn[msg.sender] = true ;
    }

    function ownerWithdraw(uint _amount) public onlyOwner{
        require(treasure >=_amount, "Amount Exceed Treasure ");
        treasure -= _amount;
    }
    function resetWithdraw(address _adr) public onlyOwner{
        withdrawn[_adr] = false ;
    }  

    function addTreasure(uint _amount) public onlyOwner {
        treasure += _amount;
    }

    function changeReward(uint newReward) public onlyOwner{
    rewardAmount = newReward;
    }

    function addUser(address _adr) public onlyOwner{
        require(!eligible[_adr], "User Already Eligible");
        eligible[_adr] = true;
    }

    function removeUser(address _adr) public onlyOwner{
        eligible[_adr] = false;
    }

    function changeOwner(address _adr) public onlyOwner{
        require(_adr != address(0), "NOT A VALID ADDRESS");
        owner = _adr;
    }
}