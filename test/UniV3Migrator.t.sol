// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Setup.sol";
import "../src/UniV3Migrator.sol";

address constant NON_FUNGIBLE_POSITION_MANAGER =
    0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

contract UniV3MigratorTest is Setup {
    UniV3Migrator public migrator;
    INonfungiblePositionManager public nonfungiblePositionManager;
    uint64 poolId;

    function setUp() public {
        vm.createSelectFork(
            "https://eth-mainnet.alchemyapi.io/v2/s33fwb9BGq-1_t_4G4u3stGB5pDU3g0f",
            17425493
        );

        _setUp();

        migrator = new UniV3Migrator(
            address(portfolio),
            NON_FUNGIBLE_POSITION_MANAGER
        );

        nonfungiblePositionManager =
            INonfungiblePositionManager(NON_FUNGIBLE_POSITION_MANAGER);

        uint24 pairId = portfolio.createPair(USDC, USDT);
        poolId = portfolio.createPool(
            pairId, address(this), 10, 100, 10_000, 365, 1000000, 1000000
        );

        vm.prank(0x3416cF6C708Da44DB2624D63ea0AAef7113527C6);
        IERC20(USDC).transfer(address(this), 1000000000);
    }

    function test_migrate() public {
        vm.prank(0x68841a1806fF291314946EebD0cdA8b348E73d6D);
        IERC20(USDT).transfer(address(this), 1000000000);

        /*

        IERC20(USDC).approve(address(portfolio), type(uint128).max);
        IERC20(USDT).approve(address(portfolio), type(uint128).max);


        portfolio.allocate(
            false,
            address(this),
            poolId,
            1 ether,
            type(uint128).max,
            type(uint128).max
        );

        */

        // We impersonate a wallet holding a large position
        vm.startPrank(0x06d039b66006c622e3afA8a99880b7c2D20154A6);

        // This is the tokenId of the position
        uint256 tokenId = 520732;
        nonfungiblePositionManager.approve(address(migrator), tokenId);

        // The next steps should be done offchain to avoid sandwich attacks

        // First we check the amount of liquidity owned by the position
        (,,,,,,, uint128 liquidityToMigrate,,,,) =
            migrator.nonfungiblePositionManager().positions(tokenId);

        // Then we can compute how much tokens we should get, remember to do this
        // offchain so you don't get sandwiched
        (, bytes memory output) = address(nonfungiblePositionManager).staticcall(
            abi.encodeWithSelector(
                nonfungiblePositionManager.decreaseLiquidity.selector,
                abi.encode(tokenId, liquidityToMigrate, 0, 0, type(uint256).max)
            )
        );

        // These amounts should be more or less what we will receive when we
        // remove the liquidity from Uniswap V3
        (uint256 amount0Min, uint256 amount1Min) =
            abi.decode(output, (uint256, uint256));

        console.log("maxLiquididddty::");

        // Using the amounts we got, we can calculate the maximum amount of
        // liquidity we can provide into the Portfolio pool
        uint128 maxLiquidity =
            portfolio.getMaxLiquidity(poolId, amount0Min, amount1Min);

        console.log("maxLiquidity", maxLiquidity);

        // From the maxLiquidity we can compute more precisely the quantity of
        // asset and quote tokens we need to provide
        (uint128 deltaAsset, uint128 deltaQuote) =
            portfolio.getLiquidityDeltas(poolId, int128(maxLiquidity));

        // Last step is simply to migrate the position!
        migrator.migrate(
            tokenId,
            liquidityToMigrate,
            amount0Min,
            amount1Min,
            poolId,
            deltaAsset,
            deltaQuote,
            maxLiquidity,
            USDC,
            USDT
        );
    }
}
