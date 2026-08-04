// Let's make your own digital currency! 
// You'll create a basic token that can be transferred between users, implementing the ERC20 standard.
// It's like creating your own in-game money, demonstrating how to create and manage tokens.

// # Concepts you will master
// 1. ERC20 interface
// 2. totalSupply
// 3. balanceOf
// 4. transfer
// 5. token basics

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract MyFirstToken{
    string public tokenName;
    string public symbol;
    uint public decimal;
    uint public totalSupply;
    mapping (address => uint ) balance ;

    event Transfer(address indexed from, address indexed to, uint amount);

    constructor(string memory _name, string memory _symbol, uint _decimal, uint _totalSupply) {
        tokenName = _name;
        symbol = _symbol;
        decimal = _decimal;
        totalSupply = _totalSupply;
        balance[msg.sender] = _totalSupply; 
    }

    mapping (address => mapping(address => uint)) details ;

    modifier validAddress(address _adr) {
        require(_adr != address(0), "INVALID ADDRESS");
        _;
    }

    function balanceOf(address _adr) public  view returns(uint){
        return balance[_adr];
    }

    function transfer(address _adr ,uint _amount) public {
        require(balance[msg.sender]>=_amount , "INSUFFICIENT BALANCE");
        balance[msg.sender] -= _amount;
        balance[_adr] += _amount;

        emit Transfer(msg.sender, _adr , _amount);
    }

    function transferFrom(address _adr1 ,address _adr2 ,uint _amount) public {
        require(balance[_adr1]>=_amount , "INSUFFICIENT BALANCE");
        balance[_adr1] -= _amount;
        balance[_adr2] += _amount;

        emit Transfer(_adr1 , _adr2 , _amount);
    }
}