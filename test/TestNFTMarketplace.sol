// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// These files are dynamically created at test time
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/NFTMarketplace.sol";

contract TestNFTMarketplace {

  // Initialize NFT market
  NFTMarketplace market = new NFTMarketplace([
      0x81471980D76Fe40b43835A887Fb43791484f42b8,
      0xCfe5ca3C095AA8f2CdCbA3AF1f326CD59Eb308E1,
      0xc344c7e9230d11E62aBEf5C9AE3258bC63E8bD4D
  ]);

  function testCreateNFT() public {

    address owner0 = market.owners[0];

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
    assert.equal(token_owner, owner0, "Incorrect NFT owner");
  }

  function testTransferNFT() public {

    // Initialize NFT market
    address owner1 = market.owners[1];
    address owner2 = market.owners[2];

    // Create NFT
    uint NFT_id = 100;
    string memory NFT_name = "Name";
    string memory NFT_desc = "Desc";
    uint newTokenCount = market.createNFT(NFT_id, NFT_name, NFT_desc);

    // Get NFT owner
    address owner = market.getTokenOwner(NFT_id);

    // Transfer NFT to another address
    market.transferNFT(NFT_id, owner1, owner2); // TODO: Modify function parameters

    // Get updated NFT owner
    address updatedOwner = market.getTokenOwner(NFT_id);

    // Assertion
    assert.equal(updatedOwner, owner2, "NFT transfer failed");

  }

  function testListNFTForSale() public {

    // Create NFT
    uint NFT_id = 100;
    string memory NFT_name = "Name";
    string memory NFT_desc = "Desc";
    uint newTokenCount = market.createNFT(NFT_id, NFT_name, NFT_desc);

    // List NFT for sale
    uint NFT_price = 10;
    market.listNFTForSale(NFT_id, NFT_price);

    // Get token info
    bool token_is_listed = market.getTokenIsListed();
    uint token_price = NFT_price;

    // Assertion
    assert.equal(token_is_listed, true, "Incorrect NFT status");
    assert.equal(token_price, price, "Incorrect NFT price");

  }
  
  function testRemoveNFTFromSale() public {

    // Create NFT
    uint NFT_id = 100;
    string memory NFT_name = "Name";
    string memory NFT_desc = "Desc";
    uint newTokenCount = market.createNFT(NFT_id, NFT_name, NFT_desc);

    // List NFT for sale
    uint NFT_price = 10;
    market.listNFTForSale(NFT_id, NFT_price);

    // Remove NFT from sale
    market.removeNFTFromSale(NFT_id);

    // Get token info
    bool token_is_listed = market.getTokenIsListed();

    // Assertion
    assert.equal(token_is_listed, false, "Incorrect NFT status");

  }

  function testPurchaseNFT() public {

    // Initialize NFT market
    address seller = market.owners[1];
    address buyer = market.owners[2];

    // Create NFT
    uint NFT_id = 100;
    string memory NFT_name = "Name";
    string memory NFT_desc = "Desc";
    uint newTokenCount = market.createNFT(NFT_id, NFT_name, NFT_desc);

    // Purchase NFT
    purchaseNFT(NFT_id, seller, buyer);

    // Get token info
    address token_owner = market.getTokenOwner(NFT_id);
    bool token_is_sold = market.getTokenIsSold(NFT_id);

    // Assertion
    assert.equal(token_owner, buyer, "Incorrect NFT owner");
    assert.equal(token_is_sold, true, "Incorrect NFT status");

  }

}
