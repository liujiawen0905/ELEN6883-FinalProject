// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NFTMarketplace is ERC721, Ownable{
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
    uint private commision_percentage;

    //mapping from token id to token information
    mapping(uint => NFT) public idToToken;

    //mapping from a user address to user's fund
    mapping(address => uint) public userFunds;

    constructor(string memory name, string memory symbol, uint percentage) ERC721(name, symbol) {
        commision_percentage = percentage;
        marketOwner = payable(msg.sender);
    }

    // Get NFT
    function getNFT(uint id) public view returns (NFT memory) {
        return idToToken[id];
    }

    // Get commision percentage
    function commissionPercentage() public view returns (uint) {
        return commision_percentage;
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
    function createNFT(uint id, string memory name, string memory description) public payable {
        _marketTokenCounts.increment();
        _safeMint(msg.sender, id);
        idToToken[id] = NFT(
            id,
            msg.sender,
            name,
            0,
            description,
            false
        );
    }

    // transfer NFT function
    function transferNFT(uint id, address toAddress) public payable{
        NFT storage item = idToToken[id];
        require(item.id == id, "The NFT must exist");
        require(item.owner == msg.sender, "Current user do not own this NFT");
        //update the details of the token
        idToToken[id].is_listed = false;
        idToToken[id].owner = toAddress;
        //Actually transfer the token to the new owner
        // setApprovalForAll(fromAddress, true);
        _transfer(msg.sender, toAddress, id);
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
        require(item.owner != msg.sender, "A NFT can not be purchased by it's owner");

        // Transfer money to the seller and the market owner
        address payable seller = payable(item.owner);
        uint256 sale_amount = item.price;
        uint256 commision_fee = sale_amount * (commision_percentage) / 100;
        seller.transfer(sale_amount - commision_fee);
        marketOwner.transfer(commision_fee);
        require(msg.value == item.price + commision_fee, "Incorrect price");

        // Transfer the NFT to the new owner and remove it from the market
        _transfer(seller, msg.sender, id);
        item.owner = msg.sender;
        item.is_listed = false;
        item.price = 0;
    }
}
