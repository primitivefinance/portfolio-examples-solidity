// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Setup.sol";
import "../src/CreatePoolExample.sol";

contract CreatePoolExampleTest is Setup {
    CreatePoolExample public example;

    function setUp() public {
        _setUp();
        example = new CreatePoolExample(
            address(portfolio),
            address(asset),
            address(quote)
        );
    }

    function test_createPool() external {
        portfolio.createPair(address(asset), address(quote));
        example.createPool();
    }
}
