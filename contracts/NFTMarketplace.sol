// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./NFT.sol";

contract NFTMarketplace {

    address payable private owner;

    using Counters for Counters.Counter;
    Counters.Counter private _marketTokenCounts;

    uint256 tokenPrice = 0.1 ether;

    NFT myNFT;

    // The structure to store info about a listed token in blockchain
    struct Token {
        uint token_idx;
        uint unique_id;
        address payable owner;
        address payable seller;
        string name;
        uint price;
        string description;
        bool is_sold;
        bool is_listed;
    } 

    //the event emitted when a token is successfully created
    event TokenCreated (
        uint indexed token_idx,
        uint unique_id,
        address owner,
        address seller,
        string name,
        string description,
        bool is_sold,
        bool is_listed
    );

    event TokenListed (
        uint indexed token_idx,
        uint unique_id,
        uint price,
        bool is_listed
    );

    event ListedTokenRemoved (
        uint indexed token_idx,
        uint unique_id,
        bool is_listed
    );

    event BuyToken (
        uint indexed token_idx,
        uint unique_id,
        bool is_sold,
        address newOwner
    );

    //mapping from token id to token information
    mapping(uint => Token) public idToToken;

    //mapping from a user address to user's fund
    mapping(address => uint) public userFunds;

    constructor(address _NFTAddress) {
        myNFT = NFT(_NFTAddress);
    }

    function getTokenPrice() public view returns(uint) {
        return tokenPrice;
    }

    // Create NFT
    function createNFT(uint id, string memory name, string memory description) public payable returns (uint){
        // increment the tokenId counter, which is keep track of the number of mined NFTs
        _marketTokenCounts.increment();
        uint newTokenCount = _marketTokenCounts.current();

         // update the mapping of tokenId's to token details
        idToToken[id] = Token(
            newTokenCount,
            id,
            payable(address(this)),
            payable(msg.sender),
            name,
            0,
            description,
            false,
            false
        );

        emit TokenCreated(
            newTokenCount,
            id,
            payable(address(this)),
            payable(msg.sender),
            name, 
            description,
            false,
            false
        );
        
        return newTokenCount;
    }

    // transfer NFT function
    function transferNFT(uint id) public payable{
        //update the details of the token
        idToToken[id].is_sold = true;
        idToToken[id].is_listed = false;
        idToToken[id].seller = payable(msg.sender);

        //Actually transfer the token to the new owner
        myNFT.transferFrom(address(this), msg.sender, id);
    }

    // list NFT for sale
    function listNFTForSale(uint id, uint price) public {
        Token storage item = idToToken[id];
        require(item.unique_id == id, "The NFT must exist");
        require(price > 0, "The price must be positive");
        require(item.owner == msg.sender, "Only the onwer can list a NFT for sale");
        require(!item.is_listed, "The NFT is already listed");

        item.is_listed = true;
        item.price = price;

        emit TokenListed (item.token_idx, id, price, true);
    }

    // remove NFT From sale
    function removeNFTFromSale(uint id) public {
        Token storage item = idToToken[id];
        require(item.unique_id == id, "The NFT must exist");
        require(item.owner == msg.sender, "The NFT can only be removed by owner");
        require(!item.is_sold, "A sold NFT cannot be removed");
        require(item.is_listed, "The NFT has not been listed yet");

        item.is_listed = false;
        emit ListedTokenRemoved(item.token_idx, id, false);
    }

    function purchaseNFT(uint id) public payable {
        Token storage item = idToToken[id];
        require(item.unique_id == id, "The NFT must exist");
        require(item.owner != msg.sender, "A NFT can not be purchased by the owner");
        require(!item.is_sold, "A sold NFT cannot be purchased");
        require(item.is_listed, "The NFT needs to be listed");
        require(msg.value >= item.price, "The buyer does not have enough money");

        transferNFT(id);
        item.is_sold = true;
        emit BuyToken(item.token_idx, id, true, msg.sender);
    }

    function claimFunds() public payable {
        // todo
    }    
}
