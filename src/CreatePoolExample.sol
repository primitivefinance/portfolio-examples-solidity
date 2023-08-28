// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";
import "portfolio/strategies/INormalStrategy.sol";

contract CreatePoolExample {
    IPortfolio public portfolio;
    address public asset;
    address public quote;

    constructor(address portfolio_, address asset_, address quote_) {
        portfolio = IPortfolio(portfolio_);
        asset = asset_;
        quote = quote_;
    }

    function createPool() external {
        // Creating a new pool is quite simple, first we need to get the pairId
        // for our asset / quote pair. We can use the function `getPairId`.
        // Note that If the `pairId` is 0, this means that we need to create
        // a new pair before trying to create the pool.
        uint24 pairId = portfolio.getPairId(asset, quote);

        // Then we need to get the correct pool configuration, we can call the
        // `getStrategyData` function from the strategy contract for this.
        // In this example, we'll use the default strategy.
        (
            bytes memory strategyArgs,
            uint256 reserveXPerWad,
            uint256 reserveYPerWad
        ) = INormalStrategy(portfolio.DEFAULT_STRATEGY()).getStrategyData(
            1 ether, 1000 wei, 10 days, false, 1 ether
        );

        // Lastly, we can call the `createPool` function with our parameters:
        portfolio.createPool(
            pairId,
            reserveXPerWad,
            reserveYPerWad,
            100,
            0,
            address(0),
            address(0),
            strategyArgs
        );
    }
}
