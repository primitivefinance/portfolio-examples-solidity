// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";

contract CreatePairExample {
    IPortfolio public portfolio;
    address public asset;
    address public quote;

    constructor(address portfolio_, address asset_, address quote_) {
        portfolio = IPortfolio(portfolio_);
        asset = asset_;
        quote = quote_;
    }

    function createPair() external {
        // Creating a new pair is extremely simple and only requires to pass the
        // address of two different tokens. Keep in mind that the decimals must
        // be between 6 and 18.
        portfolio.createPair(asset, quote);
    }
}
