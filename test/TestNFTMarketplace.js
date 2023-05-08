// Create a new instance of the smart contract
const NFTMarketplace = artifacts.require('NFTMarketplace');

contract('NFTMarketplace', (accounts) => {
  let nftMarketplace;

  before(async () => {
    nftMarketplace = await NFTMarketplace.deployed();
  });

  // Test that the smart contract can create a new NFT
  it('Test create NFT', async () => {
    // Create one user account
    const user1 = accounts[1];

    // Call the createNFT function with a unique ID, name, and description
    const nft1_id = 1;
    const nft1_name = 'NFT1';
    const nft1_description = 'DESC1';
    await nftMarketplace.createNFT(nft1_id, nft1_name, nft1_description, { from: user1 });

    // Assert that the NFT was created and its properties match the input values
    const nft1 = await nftMarketplace.getNFT(nft1_id);
    assert.equal(nft1.id, nft1_id, "Incorrect NFT id");
    assert.equal(nft1.name, nft1_name, "Incorrect NFT name");
    assert.equal(nft1.description, nft1_description, "Incorrect NFT description");
    assert.equal(nft1.owner, user1, "Incorrect NFT owner");
  });

  // Test that the smart contract can transfer ownership of an NFT
  it("Test transfer NFT", async () => {
    // Create two user accounts
    const user2 = accounts[2];
    const user3 = accounts[3];

    // Create a new NFT with the first user account
    const nft2_id = 2;
    const nft2_name = 'NFT2';
    const nft2_description = 'DESC2';
    await nftMarketplace.createNFT(nft2_id, nft2_name, nft2_description, { from: user2 });

    // Transfer ownership of the NFT to the second user account using the transferNFT function
    await nftMarketplace.transferNFT(nft2_id, user3, { from: user2 });

    // Assert that the NFT is now owned by the second user account
    const nft2_owner = await nftMarketplace.ownerOf(nft2_id);
    assert.equal(nft2_owner, user3, "Transfer NFT failed");
  });

  // Test that the smart contract can list an NFT for sale
  it("Test list NFT for sale", async () => {
    // Create a new user account
    const user4 = accounts[4];

    // Create a new NFT with the user account
    const nft3_id = 3;
    const nft3_name = "NFT3";
    const nft3_description = "DESC3";
    const nft3_price = 100;
    await nftMarketplace.createNFT(nft3_id, nft3_name, nft3_description, { from: user4 });
    
    // List the NFT for sale using the listNFTForSale function with a sale price
    await nftMarketplace.listNFTForSale(nft3_id, nft3_price, { from: user4 });

    // Assert that the NFT is now listed for sale and its sale price matches the input value
    const nft3 = await nftMarketplace.getNFT(nft3_id);
    assert.equal(nft3.is_listed, true, "NFT is not listed");
    assert.equal(nft3.price, nft3_price, "Incorrect NFT price");
  });

  // Test that the smart contract can remove an NFT from sale
  it("Test remove NFT from sale", async () => {
    // Create a new user account
    const user5 = accounts[5];

    // Create a new NFT with the user account
    const nft4_id = 4;
    const nft4_name = "NFT4";
    const nft4_description = "DESC4";
    const nft4_price = 100;
    await nftMarketplace.createNFT(nft4_id, nft4_name, nft4_description, { from: user5 });

    // List the NFT for sale using the listNFTForSale function with a sale price
    await nftMarketplace.listNFTForSale(nft4_id, nft4_price, { from: user5 });

    // Remove the NFT from sale using the removeNFTFromSale function
    await nftMarketplace.removeNFTFromSale(nft4_id, { from: user5 });

    // Assert that the NFT is no longer listed for sale
    const nft4 = await nftMarketplace.getNFT(nft4_id);
    assert.equal(nft4.is_listed, false, "Remove NFT from sale failed");
  });

  // Test that the smart contract can execute a successful NFT purchase
  it("Test purchase NFT (success)", async () => {
    // Create two user accounts
    const user5 = accounts[5]; // seller
    const user6 = accounts[6]; // buyer
  
    // Create a new NFT with the first user account
    const nft5_id = 5;
    const nft5_name = "NFT5";
    const nft5_description = "DESC5";
    const nft5_price = 100;
    await nftMarketplace.createNFT(nft5_id, nft5_name, nft5_description, { from: user5 });

    // List the NFT for sale using the listNFTForSale function with a sale price
    await nftMarketplace.listNFTForSale(nft5_id, nft5_price, { from: user5 });
  
    // Get original balances
    const seller_origin_balance = await web3.eth.getBalance(user5);

    // Get commision percentage
    const commission_percentage = await nftMarketplace.commissionPercentage();

    // Get NFT price
    const nft5 = await nftMarketplace.getNFT(nft5_id);
    const price = nft5.price;

    // Calculate commision
    const commission = price * commission_percentage / 100;

    // Make transaction
    const sale_price_BN = web3.utils.toBN(price);
    const commission_BN = web3.utils.toBN(commission);
    const total_cost = sale_price_BN.add(commission_BN);

    // Purchase the NFT using the purchaseNFT function with the second user account and the correct amount of Ether
    const tx = await nftMarketplace.purchaseNFT(nft5_id, { from: user6, value: total_cost.toString() });

    // Assert that the NFT is now owned by the second user account and the correct amount of Ether was transferred to the first user account
    
    // Check new NFT owner
    const new_nft5 = await nftMarketplace.getNFT(nft5_id);
    const new_nft5_owner = new_nft5.owner;
    assert.equal(new_nft5_owner, user6, "Transfer NFT failed");

    // Get seller's balance after
    const seller_balance_after = await web3.eth.getBalance(user5);

    // Check seller's balance after purchasement
    const fee = commission_BN;
    const expected_seller_balance_after = web3.utils.toBN(seller_origin_balance).add(sale_price_BN).sub(fee);
    assert.equal(seller_balance_after, expected_seller_balance_after.toString(), "Incorrect balance of seller");
  });

  // Test that the smart contract can execute an unsuccessful NFT purchase
  it("Test purchase NFT (failed)", async () => {
    // Create two user accounts
    const user5 = accounts[5]; // seller
    const user6 = accounts[6]; // buyer

    // Create a new NFT with the first user account
    const nft6_id = 6;
    const nft6_name = "NFT6";
    const nft6_description = "DESC6";
    const nft6_price = 100;
    await nftMarketplace.createNFT(nft6_id, nft6_name, nft6_description, { from: user5 });

    // List the NFT for sale using the listNFTForSale function with a sale price
    await nftMarketplace.listNFTForSale(nft6_id, nft6_price, { from: user5 });

    // Get original balances
    const seller_origin_balance = await web3.eth.getBalance(user5);

    // Attempt to purchase the NFT using the purchaseNFT function with the second user account but with an incorrect amount of Ether
    try {
      await nftMarketplace.purchaseNFT(nft6_id, { from: user6, value: web3.utils.toWei("33", "ether") });
    } catch (error) {
      assert(error.message.includes("Incorrect price"), "Incorrect error message");
    }

    // Get seller's balance after
    const seller_balance_after = await web3.eth.getBalance(user5);

    // Assert that the NFT ownership remains with the first user account and no Ether was transferred
    const new_nft6 = await nftMarketplace.getNFT(nft6_id);
    const new_nft6_owner = new_nft6.owner;
    assert.equal(seller_origin_balance, seller_balance_after, "Incorrect Ether amount");
    assert.equal(new_nft6_owner, user5, "Incorrect owner");
  });
});