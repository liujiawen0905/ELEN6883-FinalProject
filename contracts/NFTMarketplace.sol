// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ERC721URIStorage {

    address payable owner;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemSold;

    uint tokenPrice = 0.1 ether;

    constructor() ERC721("NFTMarketplace", "NFTM") {
        owner = payable(msg.sender);
    }

    // The structure to store info about a listed token
    struct infoListedToken {
        uint tokenId;
        address payable owner;
        address payable seller;
        string name;
        uint price;
        string description;
        bool currentListed;
    } 

    //the event emitted when a token is successfully transferred
    event TokenListedSuccess (
        uint256 indexed tokenId,
        address owner,
        address seller,
        string name,
        uint256 price,
        string description,
        bool currentlyListed
    );

    mapping(uint => infoListedToken) private idToToken;

    function updateTokenPrice(uint _tokenPrice) public payable {
        require(owner == msg.sender, "Only owner can update the listed token price");
        tokenPrice = _tokenPrice;
    }

    function getTokenPrice() public view returns(uint) {
        return tokenPrice;
    }

    //---------------------------------------------------------------------------------------------

    // Create NFT
    function createNFT(string memory name, string memory description, uint price) public payable returns (uint){
        // increment the tokenId counter, which is keep track of the number of mined NFTs
        _tokenIds.increment();
        uint newTokenId = _tokenIds.current();

        _safeMint(msg.sender, newTokenId);

        listNFTForSale(newTokenId, name, price, description);

        return newTokenId;
    }

    // List a NFT for sale
    function listNFTForSale(uint tokenId, string memory name, uint price, string memory description) private {
        
        require(msg.value == tokenPrice, "Hopefully sending the correct price");

        require(price > 0, "The price is not negative");

        // update the mapping of tokenId's to token details
        idToToken[tokenId] = infoListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            name,
            price,
            description,
            true
        );

        _transfer(msg.sender, address(this), tokenId);

        // Emit the event for successful transfer.
        emit TokenListedSuccess(
            tokenId,
            address(this),
            msg.sender,
            name,
            price,
            description,
            true
        );
    }

    // transfer NFT function
    function transferNFT(uint tokenId) public payable{
        uint _price = idToToken[tokenId].price;
        address seller = idToToken[tokenId].seller;
        require(msg.value == _price, "Make sure the purchasing price is the correct during the this transaction");

        //update the details of the token
        idToToken[tokenId].currentListed = true;
        idToToken[tokenId].seller = payable(msg.sender);
        _itemSold.increment();

        //Actually transfer the token to the new owner
        _transfer(address(this), msg.sender, tokenId);
        //approve the marketplace to sell NFTs on your behalf
        approve(address(this), tokenId);

        //Transfer the listing fee to the marketplace creator
        payable(owner).transfer(tokenPrice);
        //Transfer the proceeds from the sale to the seller of the NFT
        payable(seller).transfer(msg.value);
    }
    
}
