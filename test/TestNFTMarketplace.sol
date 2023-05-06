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
    address owner = market.owner;

    // Create NFT
    uint NFT_id = 100;
    string memory NFT_name = "Name";
    string memory NFT_desc = "Desc";
    uint newTokenCount = market.createNFT(NFT_id, NFT_name, NFT_desc);

    // Get NFT TODO: Create get token info functions
    token_id = market.getTokenId();
    token_name = market.getTokenName();
    token_desc = market.getTokenDesc();
    token_owner = market.getTokenOwner();

    // Assertion
    assert.equal(token_id, NFT_id, "Incorrect NFT ID");
    assert.equal(token_name, NFT_name, "Incorrect NFT name");
    assert.equal(token_desc, NFT_desc, "Incorrect NFT description");
    assert.equal(token_owner, owner, "Incorrect NFT owner");
  }

  function testTransferNFT() public {

    // Initialize NFT market
    NFTMarketplace market = new NFTMarketplace(0x81471980D76Fe40b43835A887Fb43791484f42b8);

  }

  function testListNFTForSale() public {

    // Initialize NFT market
    NFTMarketplace market = new NFTMarketplace(0x81471980D76Fe40b43835A887Fb43791484f42b8);

  }
  
  function testRemoveNFTFromSale() public {

    // Initialize NFT market
    NFTMarketplace market = new NFTMarketplace(0x81471980D76Fe40b43835A887Fb43791484f42b8);

  }

  function testPurchaseNFT() public {

    // Initialize NFT market
    NFTMarketplace market = new NFTMarketplace(0x81471980D76Fe40b43835A887Fb43791484f42b8);

  }

  function testInitialBalanceWithNewMetaCoin() public {
    NFTMarketplace market = new NFTMarketplace(0x81471980D76Fe40b43835A887Fb43791484f42b8);

    uint expected = 0.1 ether;

    Assert.equal(market.getTokenPrice(), expected, "Owner should have 0.1 Ether initially");
  }

}
