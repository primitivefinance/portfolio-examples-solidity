// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Setup.sol";
import "../src/CreatePairExample.sol";

contract CreatePairExampleTest is Setup {
    CreatePairExample public example;

    function setUp() public {
        _setUp();
        example = new CreatePairExample(
            address(portfolio),
            address(asset),
            address(quote)
        );
    }

    function test_createPair() external {
        example.createPair();
    }
}
