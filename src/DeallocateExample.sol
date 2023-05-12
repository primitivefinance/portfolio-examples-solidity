// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";
import "portfolio/interfaces/IERC20.sol";

contract DeallocateExample {
    IPortfolio public portfolio;
    address public asset;
    address public quote;

    constructor(address portfolio_, address asset_, address quote_) {
        portfolio = IPortfolio(portfolio_);
        asset = asset_;
        quote = quote_;
    }

    function deallocate() external {
        // Assuming we want to allocate into the pool `1099511627777`:
        uint64 poolId = 1099511627777;

        // Let's check how many tokens we have.
        uint256 assetBalance = IERC20(asset).balanceOf(address(this));
        uint256 quoteBalance = IERC20(quote).balanceOf(address(this));

        // Now we check the maximum amount of liquidity we can get from our
        // current token balances.
        uint128 maxLiquidity =
            portfolio.getMaxLiquidity(poolId, assetBalance, quoteBalance);

        // Let's use this liquidity amount to get some more precise deltas.
        (uint128 deltaAsset, uint128 deltaQuote) =
            portfolio.getLiquidityDeltas(poolId, int128(maxLiquidity));

        // We allow the portfolio contract to move our tokens.
        IERC20(asset).approve(address(portfolio), deltaAsset);
        IERC20(quote).approve(address(portfolio), deltaQuote);

        // Finally, we call the `allocate` function.
        portfolio.allocate(false, poolId, maxLiquidity, deltaAsset, deltaQuote);

        // Since we were the first liquidity provider, a part of our liquidity
        // was burnt, we need to remove that from our calculations:
        uint128 liquidity = maxLiquidity - uint128(1e9);

        // To avoid being sandwiched, we can check the minimum amount of
        // tokens that we can expect from our liquidity balance.
        (uint128 minDeltaAsset, uint128 minDeltaQuote) =
            portfolio.getLiquidityDeltas(poolId, int128(liquidity));

        // We can now deallocate the liquidity we just allocated.
        // Note that we have to remove the burnt liquidity (1e9), since we were
        // the first to provide liquidity in this pool.
        portfolio.deallocate(false, poolId, liquidity, 0, 0);
    }
}
