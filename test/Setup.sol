// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "forge-std/Test.sol";

import "portfolio/RMM01Portfolio.sol";
import "portfolio/test/SimpleRegistry.sol";
import "solmate/tokens/WETH.sol";
import "solmate/tokens/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20(name_, symbol_, decimals_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract Setup is Test {
    WETH public weth;
    RMM01Portfolio public portfolio;
    SimpleRegistry public registry;
    TestERC20 public asset;
    TestERC20 public quote;

    function _setUp() internal {
        weth = new WETH();
        registry = new SimpleRegistry();
        portfolio = new RMM01Portfolio(address(weth), address(registry));
        asset = new TestERC20("Asset", "ASSET", 18);
        quote = new TestERC20("Quote", "QUOTE", 18);
    }
}
