var Migrations = artifacts.require("./Migrations.sol");
var NFTMarketplace = artifacts.require("./NFTMarketplace.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.link(Migrations, NFTMarketplace);
  deployer.deploy(NFTMarketplace,"Columbia NFT Marketplace", "NFTM", 0.1);
};
