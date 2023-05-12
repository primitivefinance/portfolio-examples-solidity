// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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
        portfolio.createPool(
            pairId, address(0), 0, 100, 10_000, 365, 1 ether, 1 ether
        );
        example.allocate();
    }
}
