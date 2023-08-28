// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";
import "portfolio/interfaces/IERC20.sol";

contract SwapExample {
    IPortfolio public portfolio;
    address public asset;
    address public quote;

    constructor(address portfolio_, address asset_, address quote_) {
        portfolio = IPortfolio(portfolio_);
        asset = asset_;
        quote = quote_;
    }

    function swap() external {
        // Assuming we want to allocate into the pool `4294967297`:
        uint64 poolId = 4294967297;

        // Let's use a fix input amount:
        uint256 input = 1 ether;

        // Now we check how much quote tokens we can get for our input.
        uint256 output =
            portfolio.getAmountOut(poolId, true, input, address(this));

        // We approve the Portfolio contract to move our asset tokens
        IERC20(asset).approve(address(portfolio), input);

        // Then we prepare our swap order and execute it.
        Order memory order = Order({
            input: uint128(input),
            output: uint128(output),
            useMax: false,
            poolId: poolId,
            sellAsset: true
        });

        // We can also simulate the swap before executing it.
        (bool success,,) =
            portfolio.simulateSwap(order, block.timestamp, address(this));
        require(success, "Swap failed");

        portfolio.swap(order);
    }
}
