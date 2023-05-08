# Final Project for course ELEN 6883 Blockchain

## Overview
This project showcases the development and execution of a robust and effective NFT marketplace smart contract that facilitates the generation, purchase, sale, and exchange of distinctive digital assets embodied as Non-Fungible Tokens (NFTs). The undertaking encompasses the creation of an ERC-721 conforming smart contract and the integration of supplementary features to guarantee security and user-friendliness. The marketplace smart contract addresses the entire NFT lifecycle, from minting and trading to retrieval, offering a comprehensive solution for users to engage with NFTs securely and proficiently.

The testing of the NFT Collection and NFT Marketplace smart contracts, employing the Truffle framework in conjunction with Infura and Ganache, has proven successful, with all tests passing. These results substantiate that the smart contract operates as planned, enabling users to securely and efficiently list, buy, sell, and trade NFTs.

In conclusion, the project successfully developed an NFT marketplace smart contract based on the ERC-721 standard, which allows users to mint, buy, sell, and trade unique digital assets in a secure and efficient manner. The functions are correct, secure, and efficient.

## Installing
First, install the dependencies with: npm install.
Run the following command in your terminal after cloning the main repo:
$ npm install
Then, install Truffle globally by running the following command in your terminal:
$ npm install -g truffle

## Running the Tests
First, compile the smart contracts by running the following command in your terminal:
$ truffle compile
Then install and run Ganache to run your blockchain locally:
https://www.trufflesuite.com/ganache
Test that validate your solution can be executed by running the following command:
$ truffle test

## Deployment on Local Blockchain
Deploy the contracts on your Ganache local blockchain by running the following command:
$ truffle migrate

## Team member contributions

Jiawen Liu: Development environment setup, smart contract design, and testing.
Yuyang Wang, Shutong Zhang: Implementation of minting, ownership, and metadata functions.
Nina Hsu: Smart contract deployment and test case development.
Yue Rao: Project management, documentation, and quality assurance.
