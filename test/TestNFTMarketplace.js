const NFTMarketplace = artifacts.require('NFTMarketplace');

contract('NFTMarketplace', (accounts) => {
  let nftMarketplace;

  before(async () => {
    nftMarketplace = await NFTMarketplace.deployed();
  });

  // Test create NFT
  it('Test create NFT', async () => {
    // Get account addrress
    const user1 = accounts[1];

    // Declare NFT info variables
    const nft1_id = 1;
    const nft1_name = 'NFT1';
    const nft1_description = 'DESC1';

    // Create NFT
    await nftMarketplace.createNFT(nft1_id, nft1_name, nft1_description);

    // Get NFT info
    // const nft1 = await nftMarketplace.getNFT(nft1_id);
    const nft1 = await nftMarketplace.getNFT(nft1_id);

    // // Assertions
    assert.equal(nft1.id, nft1_id, "Incorrect NFT id");
    // assert.equal(nft1.name, nft1_name, "Incorrect NFT name");
    // assert.equal(nft1.description, nft1_description, "Incorrect NFT description");
    // assert.equal(nft1.owner, user1, "Incorrect NFT owner");
  });

  // Test transfer NFT
  it("Test transfer NFT", async () => {
    // Get account address
    const user2 = accounts[2];
    const user3 = accounts[3];

    // Declare NFT info variables
    const nft2_id = 2;
    const nft2_name = 'NFT2';
    const nft2_description = 'DESC2';

    // Create NFT
    await nftMarketplace.createNFT(nft2_id, nft2_name, nft2_description);

    // Transfer the NFT from user1 to user2
    await nftMarketplace.transferNFT(nft2_id, user3);

    // Assertions
    const nft2_owner = await nftMarketplace.ownerOf(nft2_id);
    assert.equal(nft2_owner, user3, "Transfer NFT failed");
  });

  // Test list NFT for sale
  it("Test list NFT for sale", async () => {
    // Get account address
    const user3 = accounts[3];

    // Declare NFT info variables
    const nft3_id = 3;
    const nft3_name = "NFT3";
    const nft3_description = "DESC3";
    const nft3_price = 1;

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
    // Get account address
    const user4 = accounts[4];

    // Declare NFT info variables
    const nft4_id = 4;
    const nft4_name = "NFT4";
    const nft4_description = "DESC4";
    const nft4_price = 1;

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
    const user5 = accounts[5];
    const user6 = accounts[6];
  
    // Declare NFT info variables
    const nft5_id = 5;
    const nft5_name = "NFT5";
    const nft5_description = "DESC5";
    const nft5_price = 1;

    // Create NFT
    await nftMarketplace.createNFT(nft5_id, nft5_name, nft5_description);

    // List the NFT for sale
    await nftMarketplace.listNFTForSale(nft5_id, nft5_price);
  
    // Get original balances
    const sellerOriginBalance = await web3.eth.getBalance(user5);

    // Get commision Percentage
    const commissionPercentage = await nftMarketplace.commissionPercentage();

    // Get NFT price
    const nftPrice = await nftMarketplace.nfts(tokenId);
    const price = nftPrice.price;

    // Calculate commision
    const commission = price * commissionPercentage / 100;

    // Make transaction
    const salePriceBN = web3.utils.toBN(salePrice);
    const commissionBN = web3.utils.toBN(commission);
    const totalCost = salePriceBN.add(commissionBN);

    // Check buyer's balance
    const buyerBalance = await web3.eth.getBalance(buyer);
    assert(web3.utils.toBN(buyerBalance).gte(totalCost), "Buyer's balance not enough");

    // purchase NFT
    const tx = await nftMarketplace.purchaseNFT(tokenId);

    // Check NFT owner
    const new_owner = await nftMarketplace.ownerOf(tokenId);
    assert.equal(new_owner, buyer, "ownership not transferred to buyer");

    // Check seller's balance
    const seller_balance_after = await web3.eth.getBalance(seller);

    // Check seller's balance after purchasement
    const fee = commissionBN;
    const expected_seller_balance_after = web3.utils.toBN(sellerBalanceBefore).add(salePriceBN).sub(fee);
    assert.equal(seller_balance_after, expected_seller_balance_after.toString(), "Incorrect balance of seller");
  });
});