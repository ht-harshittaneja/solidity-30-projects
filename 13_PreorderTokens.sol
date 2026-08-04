// Build a contract to sell your tokens for Ether. 
// You'll learn how to set a price and manage sales, demonstrating token economics. 
// It's like a pre-sale for your digital currency, showing how to sell tokens for Ether.

// # Concepts you will master
// 1. Selling tokens for Ether
// 2. rate calculations
// 3. token economics

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract PreorderTokens{
    string public tokenName = "Harshit Token";
    string public symbol = "HT";

    address owner ;
    uint public totalSupply = 10_000_000 ;
    uint public tokensAvailable = totalSupply ;
    mapping(address => uint) private htBalance;
    uint ethToHtRate = 10 ;
    
    constructor (){
        owner = msg.sender;
        htBalance[owner] = totalSupply ;
    }

    event TokensPurchased(address indexed buyer,uint etherSpent,uint tokensReceived);

    modifier onlyOwner() {
        require(owner == msg.sender ,"NOT A VALID OWNER");
        _;
    }

    function balanceOf(address _adr) public  view returns(uint){
        return htBalance[_adr];
    }

    function buyHT() payable public {
        require(msg.value>0 , "TRANSACTION VALUE MUST BE GREATER THAN 0");
        uint tokensToBuy = (msg.value * ethToHtRate) / 1 ether;
        require(tokensToBuy > 0, "Amount too small");
        require(tokensAvailable >= tokensToBuy ,"INSUFFICIENT TOKENS");
        htBalance[owner] -= tokensToBuy;
        htBalance[msg.sender] += tokensToBuy;
        tokensAvailable -= tokensToBuy;
        emit TokensPurchased(msg.sender , msg.value , tokensToBuy);
    }

    function changeRate (uint _rate) public onlyOwner {
        require(_rate > 0, "Invalid rate");
        ethToHtRate = _rate;
    }

    function withdrawETH() public onlyOwner {
        require(address(this).balance >0 ,"INSUFFICIENT BALANCE");
        (bool success ,)= payable(msg.sender).call{value : address(this).balance }("");
        require(success , "TRANSACTION FAILED");
    }

}