// Build a simple voting system where users can vote on proposals. 
// Your challenge is to make it as gas-efficient as possible. 
// Optimize how you store voter data, handle input parameters, and design functions. 
// You'll learn how `calldata`, `memory`, and `storage` affect gas usage and discover small changes that lead to big savings. 
// It's like designing a voting machine that runs faster and cheaper without losing accuracy.

// # Concepts you will master
// 1. Gas optimization
// 2. Efficient data locations
// 3. Calldata vs memory
// 4. Minimizing storage writes

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract PollStation{
    struct Proposal {
        string name;
        address creator;
        uint256 totalVotes;
    }

    mapping(address => bool) public hasVoted;
    Proposal[] public proposals;

    function createProposal(string calldata _name) external {
        proposals.push(Proposal(_name, msg.sender, 0));
    }

    function vote(uint256 proposalIndex) external { 
        require(!hasVoted[msg.sender], "Already voted"); 
        require(proposalIndex < proposals.length, "Invalid proposal"); 
        proposals[proposalIndex].totalVotes++; 
        hasVoted[msg.sender] = true; 
    }

    function totalProposals() external view returns (uint256) { 
        return proposals.length; 
    }

    function getProposal(uint proposalIndex) external view returns (string memory, address, uint256) { 
        return (
            proposals[proposalIndex].name,
            proposals[proposalIndex].creator,
            proposals[proposalIndex].totalVotes
        );
    }
}