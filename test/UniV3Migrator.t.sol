// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Setup.sol";
import "../src/UniV3Migrator.sol";

contract UniV3MigratorTest is Setup {
    UniV3Migrator public migrator;

    function setUp() public {
        vm.createSelectFork(
            "https://eth-mainnet.alchemyapi.io/v2/s33fwb9BGq-1_t_4G4u3stGB5pDU3g0f",
            17425493
        );

        _setUp();

        migrator = new UniV3Migrator(
            address(portfolio),
            0xC36442b4a4522E871399CD717aBDD847Ab11FE88
        );
    }

    function test_migrate() public {
        INonfungiblePositionManager nonfungiblePositionManager =
            migrator.nonfungiblePositionManager();
        vm.startPrank(0x06d039b66006c622e3afA8a99880b7c2D20154A6);
        nonfungiblePositionManager.approve(address(migrator), 520732);

        (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            ,
            ,
            ,
        ) = migrator.nonfungiblePositionManager().positions(520732);

        console.log(liquidity);

        migrator.migrate(520732, liquidity, 0, 0, 0, address(0), address(0));

        (
            nonce,
            operator,
            token0,
            token1,
            fee,
            tickLower,
            tickUpper,
            liquidity,
            ,
            ,
            ,
        ) = migrator.nonfungiblePositionManager().positions(520732);

        console.log(liquidity);
    }
}
