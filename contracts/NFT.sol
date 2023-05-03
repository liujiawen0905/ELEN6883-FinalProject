// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;


    event TokenMinted(
        uint tokenId,
        string tokenURI
    );

    // COLUMBIANFT is the name of token and COLUMBIA is the symbol of token
    constructor() ERC721("COLUMBIANFT", "COLUMBIA"){}

    // mint a new NFT and returns the id
    function mintToken(string memory tokenURI) public returns (uint) {
        tokenIds.increment();
        uint newTokenId = tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        emit TokenMinted(newTokenId, tokenURI);

        return newTokenId;
    }
}