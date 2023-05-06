// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// These files are dynamically created at test time
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/NFTMarketplace.sol";

contract TestNFTMarketplace {

  function testCreateNFT() public {

    // Initialize NFT market
    NFTMarketplace market = new NFTMarketplace(0x81471980D76Fe40b43835A887Fb43791484f42b8);

    // Create NFT
    uint NFT_id = 1;
    string NFT_name = "Name";
    string NFT_desc = "Desc";
    market.createNFT(NFT_id, NFT_name, NFT_desc);

    // Get NFT
    Token storage NFT = market.idToToken[NFT_id];

    // Assertion
    assert.equal(Token.unique_id, NFT_id, "Incorrect NFT ID");
    assert.equal(Token.name, NFT_name, "Incorrect NFT name");
    assert.equal(Token.description, NFT_desc, "Incorrect NFT description");
    assert.equal(Token.owner, accounts[0], "Incorrect NFT owner");
  }

  function testInitialBalanceWithNewMetaCoin() public {
    NFTMarketplace market = new NFTMarketplace(0x81471980D76Fe40b43835A887Fb43791484f42b8);

    uint expected = 0.1 ether;

    Assert.equal(market.getTokenPrice(), expected, "Owner should have 0.1 Ether initially");
  }

}
