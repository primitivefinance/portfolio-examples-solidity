// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Setup.sol";
import "../src/CreatePairExample.sol";

contract CreatePairExampleTest is Setup {
    function setUp() public {
        _setUp();
    }

    function test_createPair() external {
        portfolio.createPair(address(asset), address(quote));
    }
}
