// Let's build a simple polling station! Users will be able to vote for their favorite candidates. 
// You'll use lists (arrays, `uint[]`) to store candidate details. You'll also create a system (mappings, `mapping(address => uint)`) to remember who (their `address`) voted for which candidate. 
// Think of it as a digital voting booth. This teaches you how to manage data in a structured way.

// # Concepts You'll Master
// 1. Arrays (uint[])
// 2. Mappings (mapping(address => uint))
// 3. Simple voting logic

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract PollStation{
    string[5] private candidates = ["1- BJP" , "2- Congress" , "3- CJP" , "4- APJ" , "5- XYZ"] ;

    mapping(address => uint)  private votingDatabase ;

    function candidatesDetails() public view returns(string[5] memory){
        return candidates ;
    }

    function digitalVotingBooth(uint _no) public {
        require(votingDatabase[msg.sender] == 0, "Already voted");
        require(_no>=1 && _no<=5 ,"NOT A VALID CANDIDATE") ;
        votingDatabase[msg.sender] = _no ;
    }

    function myVote() public view returns(uint){
        return votingDatabase[msg.sender] ;
    }
}