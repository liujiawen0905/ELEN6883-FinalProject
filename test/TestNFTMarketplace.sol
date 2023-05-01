// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// These files are dynamically created at test time
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/NFTMarketplace.sol";

contract TestNFTMarketplace {

  function testInitialBalanceWithNewMetaCoin() public {
    NFTMarketplace market = new NFTMarketplace();

    uint expected = 0.1 ether;

    Assert.equal(market.getTokenPrice(), expected, "Owner should have 0.1 Ether initially");
  }

}