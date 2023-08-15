// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "forge-std/Test.sol";

import "portfolio/Portfolio.sol";
import "portfolio/test/SimpleRegistry.sol";
import "solmate/tokens/WETH.sol";
import "solmate/tokens/ERC20.sol";
import "solmate/test/utils/mocks/MockERC20.sol";

contract Setup is Test, ERC1155TokenReceiver {
    WETH public weth;
    Portfolio public portfolio;
    SimpleRegistry public registry;
    MockERC20 public asset;
    MockERC20 public quote;

    function _setUp() internal {
        weth = new WETH();
        registry = new SimpleRegistry();
        portfolio = new Portfolio(address(weth), address(registry), address(0));
        asset = new MockERC20("Asset", "ASSET", 18);
        quote = new MockERC20("Quote", "QUOTE", 18);
    }
}
