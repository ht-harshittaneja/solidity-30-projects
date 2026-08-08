// Build a marketplace for buying and selling NFTs. 
// You'll learn how to manage listings and royalties, demonstrating NFT trading. 
// It's like a digital store for collectibles, showing how to create NFT marketplaces.

// # Concepts you will master
// 1. NFT marketplace
// 2. listing/buying/selling
// 3. royalties

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract NFTMarketplace{
    IERC721 public nft;

    constructor (address _nft){
        nft = IERC721(_nft);
    }

    struct Listing{
        address seller; // USEFUL WHEN OWNER TRANSFOR USING OTHER CONTRACTS
        address creator;
        uint256 price;
    }
    uint256 public royaltyPercent = 10;

    mapping(uint256 => Listing) public listings;

    function listNft(uint256 tokenId ,uint256 _price , address _creater) external {
        require(msg.sender == nft.ownerOf(tokenId) ,"NOT OWNER");
        require(_price>0 ,"PRICE MUST BE GREATER THAN 0");
        listings[tokenId] = Listing(msg.sender, _creater , _price);
    }
    
    function buyNft(uint256 tokenId) payable external {
        require(listings[tokenId].price > 0, "NOT LISTED");
        require(nft.ownerOf(tokenId) == listings[tokenId].seller,"SELLER NOT LONGER OWNS NFT");
        require(msg.value == listings[tokenId].price  ,"VALUE SHOULD BE EQUAL TO PRICE");
    
        Listing memory item = listings[tokenId];
        delete listings[tokenId];

        nft.transferFrom(item.seller, msg.sender, tokenId);
        if (item.creator != address(0)){

            uint256 royalty = item.price * royaltyPercent / 100;
            uint256 sellerAmount = item.price - royalty;

            (bool s1,) = payable(item.creator).call{value: royalty}("");
            require(s1, "ROYALTY FAILED");

            (bool s2,) = payable(item.seller).call{value: sellerAmount}("");
            require(s2, "SELLER PAYMENT FAILED");
        }
        else {
            (bool s3,) = payable(item.seller).call{value: item.price}("");
            require(s3, "SELLER PAYMENT FAILED");
        }
    }

    function nftPrice(uint256 tokenId) public view returns(uint256){
        return listings[tokenId].price ;
    }
    function cancelListing(uint256 tokenId) external {
        require(nft.ownerOf(tokenId) == msg.sender ,"NOT OWNER");
        delete listings[tokenId];
    }
}