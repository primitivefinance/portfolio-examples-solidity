// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";

contract CreatePairExample {
    IPortfolio public portfolio;

    constructor(address portfolio_) {
        portfolio = IPortfolio(portfolio_);
    }

    function createPair(address asset, address quote) external {
        portfolio.createPair(asset, quote);
    }
}
