// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";

contract CreatePoolExample {
    IPortfolio public portfolio;

    constructor(address portfolio_) {
        portfolio = IPortfolio(portfolio_);
    }

    function createPool(address asset, address quote) external {
        uint24 pairId = portfolio.getPairId(asset, quote);

        portfolio.createPool(
            pairId, address(this), 10, 100, 10_000, 365, 1 ether, 1 ether
        );
    }
}
