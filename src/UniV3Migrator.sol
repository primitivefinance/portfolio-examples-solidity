// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";
import "portfolio/interfaces/IERC20.sol";

struct DecreaseLiquidityParams {
    uint256 tokenId;
    uint128 liquidity;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
}

interface IERC721Permit {
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}

interface INonfungiblePositionManager {
    function decreaseLiquidity(DecreaseLiquidityParams memory params)
        external
        returns (uint256 amount0, uint256 amount1);

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    function approve(address spender, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract UniV3Migrator {
    IPortfolio public portfolio;
    INonfungiblePositionManager public nonfungiblePositionManager;

    constructor(address _portfolio, address _nonfungiblePositionManager) {
        portfolio = IPortfolio(_portfolio);
        nonfungiblePositionManager =
            INonfungiblePositionManager(_nonfungiblePositionManager);
    }

    function migrate(
        uint256 tokenId,
        uint128 liquidity,
        uint256 amount0Min,
        uint256 amount1Min,
        uint64 poolId,
        uint128 maxDeltaAsset,
        uint128 maxDeltaQuote,
        uint128 deltaLiquidity,
        address asset,
        address quote
    ) external {
        // First let's transfer the position NFT into this contract.
        nonfungiblePositionManager.transferFrom(
            msg.sender, address(this), tokenId
        );

        // Then we remove the liquidity from the Uniswap V3 pool.
        DecreaseLiquidityParams memory params = DecreaseLiquidityParams({
            tokenId: tokenId,
            liquidity: liquidity,
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            deadline: block.timestamp
        });
        (uint256 amount0, uint256 amount1) =
            nonfungiblePositionManager.decreaseLiquidity(params);

        // Now we add the liquidity to the Portfolio pool.
        (uint256 deltaAsset, uint256 deltaQuote) = portfolio.allocate(
            false, poolId, deltaLiquidity, maxDeltaAsset, maxDeltaQuote
        );
    }
}
