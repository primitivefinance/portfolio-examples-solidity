// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";
import "portfolio/interfaces/IERC20.sol";

address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

contract DellocateExample {
    IPortfolio public portfolio;

    constructor(address portfolio_) {
        portfolio = IPortfolio(portfolio_);
    }

    function deallocate() external {
        // Assuming we want to allocate into a USDC-USDT pool, with an id of 2;
        uint64 poolId = 2;

        // Let's check how many tokens do we have.
        uint256 usdcBalance = IERC20(USDC).balanceOf(address(this));
        uint256 usdtBalance = IERC20(USDT).balanceOf(address(this));

        // Now we check the maximum amount of liquidity we can get from our
        // current token balances.
        uint128 maxLiquidity =
            portfolio.getMaxLiquidity(poolId, usdcBalance, usdtBalance);

        // Let's use this liquidity amount to get some more precise deltas.
        (uint128 deltaAsset, uint128 deltaQuote) =
            portfolio.getLiquidityDeltas(poolId, int128(maxLiquidity));

        // We allow the portfolio contract to move our tokens.
        IERC20(USDC).approve(address(portfolio), deltaAsset);
        IERC20(USDT).approve(address(portfolio), deltaQuote);

        // We call the `allocate` function.
        portfolio.allocate(
            false,
            poolId,
            maxLiquidity,
            uint128(deltaAsset),
            uint128(deltaQuote)
        );

        // To avoid being sandwiched, we can check the minimum amount of
        // tokens that we can expect from our liquidity.
        (uint128 minDeltaAsset, uint128 minDeltaQuote) =
            portfolio.getLiquidityDeltas(poolId, int128(maxLiquidity));

        // We can now deallocate the liquidity we just allocated.
        portfolio.deallocate(
            false, poolId, maxLiquidity, minDeltaAsset, minDeltaQuote
        );
    }
}
