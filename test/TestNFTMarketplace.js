const NFTMarketplace = artifacts.require('NFTMarketplace');

contract('NFTMarketplace', (accounts) => {
  let nftMarketplace;

  before(async () => {
    nftMarketplace = await NFTMarketplace.deployed();
  });

  // Test create NFT
  it('Test create NFT', async () => {
    // Get account address
    const user1 = accounts[1];

    // Declare NFT info variables
    const nft1_id = 1;
    const nft1_name = 'NFT1';
    const nft1_description = 'DESC1';

    // Create NFT
    await nftMarketplace.createNFT(nft1_id, nft1_name, nft1_description, { from: user1 });

    // Get NFT info
    const nft1 = await nftMarketplace.getNFT(nft1_id);

    // // Assertions
    assert.equal(nft1.id, nft1_id, "Incorrect NFT id");
    assert.equal(nft1.name, nft1_name, "Incorrect NFT name");
    assert.equal(nft1.description, nft1_description, "Incorrect NFT description");
    assert.equal(nft1.owner, user1, "Incorrect NFT owner");
  });

  // Test transfer NFT
  it("Test transfer NFT", async () => {
    // Get account address
    const user2 = accounts[2];

    // Declare NFT info variables
    const nft2_id = 2;
    const nft2_name = 'NFT2';
    const nft2_description = 'DESC2';

    // Create NFT
    await nftMarketplace.createNFT(nft2_id, nft2_name, nft2_description);

    // Transfer the NFT to user2
    await nftMarketplace.transferNFT(nft2_id, user2);

    // Assertions
    const nft2_owner = await nftMarketplace.ownerOf(nft2_id);
    assert.equal(nft2_owner, user2, "Transfer NFT failed");
  });

  // Test list NFT for sale
  it("Test list NFT for sale", async () => {
    // Declare NFT info variables
    const nft3_id = 3;
    const nft3_name = "NFT3";
    const nft3_description = "DESC3";
    const nft3_price = 100;

    // Create NFT
    await nftMarketplace.createNFT(nft3_id, nft3_name, nft3_description);
    
    // List the NFT for sale
    await nftMarketplace.listNFTForSale(nft3_id, nft3_price);

    // Assertions
    const nft3 = await nftMarketplace.getNFT(nft3_id);
    assert.equal(nft3.is_listed, true, "NFT is not listed");
    assert.equal(nft3.price, nft3_price, "Incorrect NFT price");
  });

  // Test remove NFT from sale
  it("Test remove NFT from sale", async () => {
    // Declare NFT info variables
    const nft4_id = 4;
    const nft4_name = "NFT4";
    const nft4_description = "DESC4";
    const nft4_price = 100;

    // Create NFT
    await nftMarketplace.createNFT(nft4_id, nft4_name, nft4_description);

    // List the NFT for sale
    await nftMarketplace.listNFTForSale(nft4_id, nft4_price);

    // Remove the NFT from sale
    await nftMarketplace.removeNFTFromSale(nft4_id);

    // Assertions
    const nft4 = await nftMarketplace.getNFT(nft4_id);
    assert.equal(nft4.is_listed, false, "Remove NFT from sale failed");
  });

  // Test purchase NFT
  it("Test purchase NFT", async () => {
    // Get account address
    const user5 = accounts[5]; // seller
    const user6 = accounts[6]; // buyer
  
    // Declare NFT info variables
    const nft5_id = 5;
    const nft5_name = "NFT5";
    const nft5_description = "DESC5";
    const nft5_price = 100;

    // Create NFT
    await nftMarketplace.createNFT(nft5_id, nft5_name, nft5_description, { from: user5 });

    // List the NFT for sale
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

    // Check the NFT owner
    assert.equal(nft5.owner, user5, "Incorrect owner");

    // purchase NFT
    const tx = await nftMarketplace.purchaseNFT(nft5_id, { from: user6, value: total_cost.toString() });

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
});