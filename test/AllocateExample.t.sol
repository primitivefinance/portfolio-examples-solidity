// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/strategies/INormalStrategy.sol";
import "portfolio/libraries/AssemblyLib.sol";
import "./Setup.sol";
import "../src/AllocateExample.sol";

contract AllocateExampleTest is Setup {
    AllocateExample public example;

    function setUp() public {
        _setUp();
        example = new AllocateExample(
            address(portfolio),
            address(asset),
            address(quote)
        );

        asset.mint(address(example), 100 ether);
        quote.mint(address(example), 100 ether);
    }

    function test_allocate() external {
        uint24 pairId = portfolio.createPair(address(asset), address(quote));
        (
            bytes memory strategyArgs,
            uint256 reserveXPerWad,
            uint256 reserveYPerWad
        ) = INormalStrategy(portfolio.DEFAULT_STRATEGY()).getStrategyData(
            AssemblyLib.scaleToWad(1000 * 10 ** 6, 6),
            1_000,
            10 days,
            false,
            AssemblyLib.scaleToWad(1000 * 10 ** 6, 6)
        );

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

        example.allocate();
    }
}
