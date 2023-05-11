// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";

contract MulticallExample {
    IPortfolio public portfolio;

    constructor(address portfolio_) {
        portfolio = IPortfolio(portfolio_);
    }

    /**
     * @notice Creates a pair and a pool in a single transaction by calling the
     * `multicall` function.
     * @param asset Address of the asset token.
     * @param quote Address of the quote token.
     */
    function createPairAndPool(address asset, address quote) external {
        // Let's prepare the data for our multicall.
        bytes[] memory data = new bytes[](2);

        // First, let's create the pair.
        data[0] = abi.encodeCall(IPortfolioActions.createPair, (asset, quote));

        // Second, let's create the pool. Note that we are using the pairId 0,
        // this is a "magic value" referring to the last pair created.
        data[1] = abi.encodeCall(
            IPortfolioActions.createPool,
            (0, address(this), 10, 100, 10_000, 365, 1 ether, 1 ether)
        );

        // Finally, let's call the multicall function.
        portfolio.multicall(data);
    }
}