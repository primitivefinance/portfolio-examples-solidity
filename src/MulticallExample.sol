// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";

contract MulticallExample {
    IPortfolio public portfolio;

    constructor(address portfolio_) {
        portfolio = IPortfolio(portfolio_);
    }

    function createPairAndPool(address asset, address quote) external {
        // In this example, we are going to create a new pair and a new pool in
        // one unique transaction.

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

    function createPairAndPoolAndAllocate(
        address asset,
        address quote
    ) external {
        // In this example, we are going to create a new pair, a new pool and
        // allocate liquidity in the same transaction.

        // Let's prepare the data for our multicall.
        bytes[] memory data = new bytes[](3);

        // First, let's create the pair.
        data[0] = abi.encodeCall(IPortfolioActions.createPair, (asset, quote));

        // Second, let's create the pool. Note that we are using the pairId 0,
        // this is a "magic value" referring to the last pair created.
        data[1] = abi.encodeCall(
            IPortfolioActions.createPool,
            (0, address(this), 10, 100, 10_000, 365, 1 ether, 1 ether)
        );

        // Third, let's allocate into the pool. Note that we are using poolId 0,
        // this is a "magic value" referring to the last pool created.
        data[2] = abi.encodeCall(
            IPortfolioActions.allocate,
            (false, 0, 1 ether, type(uint128).max, type(uint128).max)
        );

        // Finally, let's call the multicall function.
        portfolio.multicall(data);
    }
}
