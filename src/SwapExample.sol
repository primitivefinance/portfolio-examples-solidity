// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";
import "portfolio/interfaces/IERC20.sol";

address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

contract SwapExample {
    IPortfolio public portfolio;

    constructor(address portfolio_) {
        portfolio = IPortfolio(portfolio_);
    }

    function swap() external {
        // Assuming we want to swap into a USDC-USDT pool, with 2 as a poolId.
        uint64 poolId = 2;

        // Let's fetch our USDC balance and use it for the swap.
        uint256 input = IERC20(USDC).balanceOf(address(this));

        // We approve the Portfolio contract to move our USDC tokens
        IERC20(USDC).approve(address(portfolio), input);

        // Now we check how much USDT we can get for our USDC.
        uint256 output =
            portfolio.getAmountOut(poolId, true, input, 0, address(this));

        // Then we prepare our swap order and execute it.
        Order memory order = Order({
            input: uint128(input),
            output: uint128(output),
            useMax: false,
            poolId: poolId,
            sellAsset: true
        });

        portfolio.swap(order);
    }
}
