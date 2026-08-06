// Create your own digital collectibles (NFTs)! 
// You'll learn how to make unique digital items by implementing the ERC721 standard and storing metadata. 
// It's like creating digital trading cards, demonstrating NFT creation.

// # Concepts you will master
// 1. ERC721 basics
// 2. minting NFTs
// 3. metadata storage

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract SimpleNFT {
    string public name = "DlfCamellias";
    string public symbol = "DC";
    mapping(uint256 => address) private owners;
    mapping(address => uint256) private balances;
    mapping(uint256 => string) public tokenURI;
    mapping(uint256 => address) approved;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owners, address indexed approved,uint256 indexed tokenId);

    function balanceOf(address user) external view returns(uint256){
        return balances[user];
    }

    function ownerOf(uint256 tokenId) external view returns(address){
        return owners[tokenId] ;
    }

    function transfer(address to, uint256 tokenId) external {
        require(owners[tokenId] == msg.sender ,"NOT owners");
        require(to != address(0),"ADDRESS SHOULD NOT BE ZERO");
        balances[msg.sender]-- ;
        owners[tokenId] = to;
        balances[to]++;
        delete approved[tokenId];
        emit Transfer(msg.sender , to, tokenId);
    }

    function mint(uint256 tokenId , string calldata _tokenURI) external {
        require(owners[tokenId] == address(0) ,"NFT NOT VALID");
        owners[tokenId] = msg.sender;
        tokenURI[tokenId] = _tokenURI ;
        balances[msg.sender]++;
        emit Transfer(address(0), msg.sender , tokenId);
    }

    function approve(address user,uint256 tokenId) external{
        require(user != msg.sender, "ALREADY OWNER");
        require(owners[tokenId] == msg.sender,"NOT OWNER");
        approved[tokenId] = user;
        emit Approval(msg.sender, user, tokenId);
    }

    function transferApproved(address to , uint256 tokenId ) external {
        require(approved[tokenId] == msg.sender ,"NOT APPROVED");
        require(to != address(0), "ADDRESS SHOULD NOT BE ZERO");
        address previousOwner = owners[tokenId];
        balances[owners[tokenId]]-- ;
        owners[tokenId] = to;
        delete approved[tokenId] ;
        balances[to]++;
        emit Transfer(previousOwner , to, tokenId);
    }

    function whoseApproved(uint256 tokenId) external view returns(address){
        return approved[tokenId];
    }

    function burn(uint256 tokenId) external{
        require(owners[tokenId] == msg.sender,"Not owners");
        delete owners[tokenId];
        delete approved[tokenId];
        delete tokenURI[tokenId];
        balances[msg.sender]--;
        emit Transfer(msg.sender , address(0), tokenId);
    }
}