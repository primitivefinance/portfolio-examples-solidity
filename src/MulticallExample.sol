// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";
import "portfolio/strategies/INormalStrategy.sol";
import "portfolio/libraries/AssemblyLib.sol";

contract MulticallExample {
    IPortfolio public portfolio;
    address public asset;
    address public quote;

    constructor(address portfolio_, address asset_, address quote_) {
        portfolio = IPortfolio(portfolio_);
        asset = asset_;
        quote = quote_;
    }

    function createPairAndPool() external {
        // In this example, we are going to create a new pair and a new pool in
        // one unique transaction.

        // Let's prepare the data for our multicall.
        bytes[] memory data = new bytes[](2);

        // First, let's create the pair.
        data[0] = abi.encodeCall(IPortfolioActions.createPair, (asset, quote));

        // Second, let's create the pool. Note that we are using the pairId 0,
        // this is a "magic value" referring to the last pair created.
        (
            bytes memory strategyArgs,
            uint256 reserveXPerWad,
            uint256 reserveYPerWad
        ) = INormalStrategy(portfolio.DEFAULT_STRATEGY()).getStrategyData(
            AssemblyLib.scaleToWad(1600 * 10 ** 6, 6),
            1_000,
            10 days,
            false,
            AssemblyLib.scaleToWad(1600 * 10 ** 6, 6)
        );

        data[1] = abi.encodeCall(
            IPortfolioActions.createPool,
            (
                0,
                reserveXPerWad,
                reserveYPerWad,
                100,
                0,
                address(0),
                address(0),
                strategyArgs
            )
        );

        // Finally, let's call the multicall function.
        portfolio.multicall(data);
    }

    function createPairAndPoolAndAllocate() external {
        // In this example, we are going to create a new pair, a new pool and
        // allocate liquidity in the same transaction.

        // Let's prepare the data for our multicall.
        bytes[] memory data = new bytes[](3);

        // First, let's create the pair.
        data[0] = abi.encodeCall(IPortfolioActions.createPair, (asset, quote));

        // Second, let's create the pool. Note that we are using the pairId 0,
        // this is a "magic value" referring to the last pair created.
        (
            bytes memory strategyArgs,
            uint256 reserveXPerWad,
            uint256 reserveYPerWad
        ) = INormalStrategy(portfolio.DEFAULT_STRATEGY()).getStrategyData(
            AssemblyLib.scaleToWad(1600 * 10 ** 6, 6),
            1_000,
            10 days,
            false,
            AssemblyLib.scaleToWad(1600 * 10 ** 6, 6)
        );

        data[1] = abi.encodeCall(
            IPortfolioActions.createPool,
            (
                0,
                reserveXPerWad,
                reserveYPerWad,
                100,
                0,
                address(0),
                address(0),
                strategyArgs
            )
        );

        // Third, let's allocate into the pool. Note that we are using poolId 0,
        // this is a "magic value" referring to the last pool created.
        data[2] = abi.encodeCall(
            IPortfolioActions.allocate,
            (
                false,
                address(this),
                0,
                1 ether,
                type(uint128).max,
                type(uint128).max
            )
        );

        // Finally, let's call the multicall function.
        portfolio.multicall(data);
    }
}
