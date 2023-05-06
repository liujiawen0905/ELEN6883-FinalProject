// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _marketTokenCounts;

    // The structure to store info about a NFT in blockchain
    struct NFT {
        uint id;
        address owner;
        string name;
        uint price;
        string description;
        bool is_listed;
    }

    address payable private marketOwner;
    uint private royalty_percentage;

    uint256 tokenPrice = 0.1 ether;

    //mapping from token id to token information
    mapping(uint => NFT) public idToToken;

    //mapping from a user address to user's fund
    mapping(address => uint) public userFunds;

    constructor(string memory name, string memory symbol, uint percentage) ERC721(name, symbol){
        royalty_percentage = percentage;
        marketOwner = payable(msg.sender);
    }

    function getTokenPrice() public view returns(uint) {
        return tokenPrice;
    }

    // mint a new NFT and returns the id
    function mintNFT() public returns (uint) {
        // increment the tokenId counter, which is keep track of the number of mined NFTs
        _marketTokenCounts.increment();
        uint newTokenId = _marketTokenCounts.current();
        _safeMint(msg.sender, newTokenId);
        idToToken[newTokenId] = NFT(
            newTokenId, 
            msg.sender, 
            "NULL", 
            0 , 
            "NULL", 
            false
            );
        return newTokenId;
    }

    // Create NFT
    function createNFT(uint id, string memory name, string memory description) public payable returns (uint){
        _marketTokenCounts.increment();
        uint newTokenId = _marketTokenCounts.current();
        idToToken[id] = NFT(
            id,
            payable(msg.sender),
            name,
            0,
            description,
            false
        );
        return newTokenId;
    }

    // transfer NFT function
    function transferNFT(uint id, address toAddress) public payable{
        NFT storage item = idToToken[id];
        require(item.id == id, "The NFT must exist");
        require(ownerOf(id) == msg.sender, "Current user do not own this NFT");
        //update the details of the token
        idToToken[id].is_listed = false;
        idToToken[id].owner = toAddress;
        //Actually transfer the token to the new owner
        safeTransferFrom(address(this), toAddress, id);
    }

    // list NFT for sale
    function listNFTForSale(uint id, uint price) public {
        NFT storage item = idToToken[id];
        require(item.id == id, "The NFT must exist");
        require(price > 0, "The price must be positive");
        require(item.owner == msg.sender, "Only the onwer can list a NFT for sale");
        require(!item.is_listed, "The NFT is already listed");
        item.is_listed = true;
        item.price = price;
    }

    // remove NFT From sale
    function removeNFTFromSale(uint id) public {
        NFT storage item = idToToken[id];
        require(item.id == id, "The NFT must exist");
        require(item.owner == msg.sender, "The NFT can only be removed by owner");
        require(item.is_listed, "The NFT has not been listed yet");
        item.is_listed = false;
    }

    function purchaseNFT(uint id) public payable {
        NFT storage item = idToToken[id];
        require(item.is_listed, "The NFT needs to be listed to be purchased");
        require(item.id == id, "The NFT must exist");
        require(item.owner != msg.sender, "A NFT can not be purchased by the owner");
        require(msg.value >= item.price, "The buyer does not have enough money");

        // transfer money to seller and market owner
        address payable seller = payable(item.owner);
        uint256 sale_amount = item.price;
        uint256 royalty_fee = sale_amount * (royalty_percentage) / 100;
        seller.transfer(sale_amount);
        marketOwner.transfer(royalty_fee);

        //Actually transfer the NFT to the new owner
        item.is_listed = false;
        item.price = 0;
        item.owner = msg.sender;
        safeTransferFrom(seller, msg.sender, id);
    }
}
