// Create a basic auction! Users can bid on an item, and the highest bidder wins when time runs out. 
// You'll use 'if/else' to decide who wins based on the highest bid and track time using the blockchain's clock (`block.timestamp`). 
// This is like a simple version of eBay on the blockchain, showing how to control logic based on conditions and time.

// # Concepts You'll Master
// 1. if/else statements
// 2. Time (block.timestamp)
// 3. Basic bidding

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract AuctionHouse{
    uint private duration ;
    uint private starting ;
    uint public deadline;
    constructor() {
    duration =300 ;
    starting = block.timestamp;
    deadline = starting + duration;
    }
    uint public startingBid = 30 ;
    uint public minimumRaise =10 ;
    uint public maxBid ;
    string private winnerName ;
    address private highestBidder ;


    function bid(string memory fullName ,uint currentBid) public{
        require(block.timestamp < deadline, "Auction ended");

        if(maxBid == 0) {
            require(currentBid > startingBid,"Bid amounting should be strictly greater than starting Bid");
            maxBid = currentBid ;
            winnerName = fullName;
            highestBidder = msg.sender ;
        }
        else {
        require(currentBid > maxBid ,"Bid amounting should be strictly greater than Maximum Bid currently");
        require((currentBid-maxBid)>=minimumRaise,"Bid raise should be greater than equal to 10");
        maxBid = currentBid ;
        winnerName = fullName;
        highestBidder = msg.sender ;
        }
    }

    function timeRemaining() public view returns(uint){
        if (block.timestamp >= deadline) {
        return 0;
        }
        else return deadline - block.timestamp;
    }

    function winner() public view returns(string memory , address ){
        require(block.timestamp >= deadline , "time remaining");
        return (winnerName , highestBidder) ;
    }
}