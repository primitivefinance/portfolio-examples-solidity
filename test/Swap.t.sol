// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Setup.sol";
import "../src/SwapExample.sol";

contract SwapExampleTest is Setup {
    SwapExample public example;

    function setUp() public {
        _setUp();
        example = new SwapExample(
            address(portfolio),
            address(asset),
            address(quote)
        );

        asset.mint(address(example), 1 ether);
        quote.mint(address(example), 1 ether);

        asset.mint(address(this), 100 ether);
        quote.mint(address(this), 100 ether);

        asset.approve(address(portfolio), 100 ether);
        quote.approve(address(portfolio), 100 ether);
    }

    function test_swap() external {
        uint24 pairId = portfolio.createPair(address(asset), address(quote));
        portfolio.createPool(
            pairId, address(0), 0, 100, 10_000, 365, 1 ether, 1 ether
        );

        uint64 poolId = 1099511627777;
        uint256 assetBalance = asset.balanceOf(address(this));
        uint256 quoteBalance = quote.balanceOf(address(this));

        uint128 maxLiquidity =
            portfolio.getMaxLiquidity(poolId, assetBalance, quoteBalance);

        (uint128 deltaAsset, uint128 deltaQuote) =
            portfolio.getLiquidityDeltas(poolId, int128(maxLiquidity));

        asset.approve(address(portfolio), deltaAsset);
        quote.approve(address(portfolio), deltaQuote);

        portfolio.allocate(
            false, address(this), poolId, maxLiquidity, deltaAsset, deltaQuote
        );

        example.swap();
    }
}
