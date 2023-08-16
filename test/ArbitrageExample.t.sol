// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/strategies/INormalStrategy.sol";
import "./Setup.sol";
import "../src/ArbitrageExample.sol";

contract ArbitrageExampleTest is Setup {
    ArbitrageExample public example;

    // Second pool tokens.
    MockERC20 public asset_2;
    MockERC20 public quote_2;

    /// @dev Meta-tokens are ERC20 wrappers for 1+ ERC1155 pool tokens.
    ERC20Wrapper public metaToken;

    function setUp() public {
        _setUp();

        example = new ArbitrageExample(
            address(portfolio),
            address(asset),
            address(quote)
        );

        // Make a new pair of tokens to create another pool from.
        asset_2 = new MockERC20("Asset2", "A2", 18);
        quote_2 = new MockERC20("Quote2", "Q2", 18);
        vm.label(address(asset_2), "asset_2");
        vm.label(address(quote_2), "quote_2");

        // Mint tokens to this contract so it can mint the ERC1155 tokens.
        asset.mint(address(this), 100 ether);
        quote.mint(address(this), 100 ether);
        asset_2.mint(address(this), 100 ether);
        quote_2.mint(address(this), 100 ether);

        // Approve portfolio to take all the tokens from this contract.
        asset.approve(address(portfolio), 100 ether);
        quote.approve(address(portfolio), 100 ether);
        asset_2.approve(address(portfolio), 100 ether);
        quote_2.approve(address(portfolio), 100 ether);
    }

    /// @dev A meta-token is an ERC20 wrapper for more than one 1155 Portfolio pool tokens.
    function test_arbitrage_meta_token() external {
        // Create the pair token for the first pool.
        uint24 pairId_1 = portfolio.createPair(address(asset), address(quote));
        (
            bytes memory strategyArgs,
            uint256 reserveXPerWad,
            uint256 reserveYPerWad
        ) = INormalStrategy(portfolio.DEFAULT_STRATEGY()).getStrategyData(
            1 ether, 1000 wei, 10 days, false, 1 ether
        );

        // Create the first pool.
        uint64 poolId_1 = portfolio.createPool(
            pairId_1,
            reserveXPerWad,
            reserveYPerWad,
            100,
            0,
            address(0),
            address(0),
            strategyArgs
        );

        // Create the pair token for the second pool.
        uint24 pairId_2 =
            portfolio.createPair(address(asset_2), address(quote_2));
        (strategyArgs, reserveXPerWad, reserveYPerWad) = INormalStrategy(
            portfolio.DEFAULT_STRATEGY()
        ).getStrategyData(1 ether, 1000 wei, 10 days, false, 1 ether);

        // Create the second pool.
        uint64 poolId_2 = portfolio.createPool(
            pairId_2,
            reserveXPerWad,
            reserveYPerWad,
            100,
            0,
            address(0),
            address(0),
            strategyArgs
        );

        // Create the meta-token ERC20.
        uint64[] memory poolIds = new uint64[](2);
        poolIds[0] = poolId_1;
        poolIds[1] = poolId_2;
        metaToken =
            new ERC20Wrapper(address(portfolio), poolIds, "MetaToken", "MT");
        vm.label(address(metaToken), "metaToken");

        // Amount of liquidity to mint of each pool and amount of meta-tokens to mint.
        uint128 amount = 1 ether;
        // First liquidity add requires 1e9 of liquidity to be locked.
        // Need to make sure we end up with at least `amount` of liquidity.
        uint128 burned_liquidity = 1e9;

        // Allocate some initial liquidity to both to get ERC1155 tokens.
        // This is allocating from this test contract, using tokens minted in setUp.
        portfolio.allocate(
            false,
            address(this),
            poolId_1,
            amount + burned_liquidity,
            100 ether,
            100 ether
        );
        portfolio.allocate(
            false,
            address(this),
            poolId_2,
            amount + burned_liquidity,
            100 ether,
            100 ether
        );

        // Approve the meta-token to take this test contract's ERC1155 tokens.
        portfolio.setApprovalForAll(address(metaToken), true);

        // Issue the meta-token ERC20 by using the ERC1155 tokens we received.
        metaToken.mint(address(this), amount);

        // Send the meta tokens to the arbitrage example contract.
        metaToken.transfer(address(example), amount);

        // Arbitrage the meta-token.
        example.arbitrage_meta(address(metaToken));
    }
}
