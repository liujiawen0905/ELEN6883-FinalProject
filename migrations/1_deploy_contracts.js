const NFT = artifacts.require("NFT");
const NFTMarketplace = artifacts.require("NFTMarketplace");


module.exports = function(deployer) {
  deployer.deploy(NFT);
  deployer.link(NFT, NFTMarketplace);
  deployer.deploy(NFTMarketplace, "0x81471980D76Fe40b43835A887Fb43791484f42b8");
};
