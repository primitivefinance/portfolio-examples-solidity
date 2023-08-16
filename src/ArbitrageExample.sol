// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "portfolio/interfaces/IPortfolio.sol";
import "portfolio/interfaces/IERC20.sol";
import "solmate/tokens/ERC1155.sol";
import "erc20-wrapper/ERC20Wrapper.sol";

contract ArbitrageExample is ERC1155TokenReceiver {
    IPortfolio public portfolio;
    address public asset;
    address public quote;

    uint64[] public receivedPoolTokens;
    bytes[] public calls;

    constructor(address portfolio_, address asset_, address quote_) {
        portfolio = IPortfolio(portfolio_);
        asset = asset_;
        quote = quote_;
    }

    /// @dev todo
    function arbitrage() external {}

    /// @dev Example
    /// Assume I receive 1 meta-token, which is an ERC20 wrapper for 1+ ERC1155 pool tokens.
    /// For example, it's price is $0.9 on a DEX but its underlying assets are worth $1.0.
    /// To arbitrage this meta-token, I need to:
    /// 1. Purchase the 1 meta-token from the DEX for $0.9.
    /// 2. Redeem the meta-token for its underlying ERC1155 pool tokens.
    /// 3. Burn the ERC1155 pool tokens for their underlying ERC20 tokens.
    /// 4. Pay for the trade initiated in step 1), swap some of the tokens, or keep them all.
    function arbitrage_meta(address metaToken) external {
        // Initiate a swap on a DEX that optimistically transfers this contract the desired output tokens
        // which are meta-tokens (ERC20).
        // note: This is a placeholder, it does not do anything.
        receive_meta_tokens();

        // Redeem meta-token
        uint256 balance = ERC20Wrapper(metaToken).balanceOf(address(this));
        // This triggers the ERC1155 tokens of the meta-token pool to be sent to this contract.
        ERC20Wrapper(metaToken).burn(address(this), balance);

        // Remove liquidity from the ERC115 pool tokens.
        uint256 pools = receivedPoolTokens.length;
        for (uint256 i; i < pools;) {
            uint64 poolId = receivedPoolTokens[i];
            calls.push(
                abi.encodeWithSelector(
                    IPortfolioActions.deallocate.selector,
                    true, // useMax: this flag will use this contract's entire ERC1155 balance.
                    receivedPoolTokens[i],
                    0, // deltaLiquidity: we are using the useMax flag instead.
                    0, // minAssetReceived: This should be set in production to mitigate sandwich attacks.
                    0 // minQuoteReceived: This should be set in production to mitigate sandwich attacks.
                )
            );
            unchecked {
                ++i;
            }
        }

        // Execute all the deallocate calls in one transaction!
        portfolio.multicall(calls);

        // Send the tokens to pay the DEX, or anyone else, back!
        use_underlying_tokens();

        // Clear the pools we kept track of in `onERC1155BatchReceived`.
        delete receivedPoolTokens;
    }

    /// @dev On meta-token redemption, this hook will get called since the
    /// redeemer will receive the ERC1155 pool tokens.
    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external virtual override returns (bytes4) {
        // Keep track of the tokens we received, since they are the poolIds to
        // remove liquidity from.
        uint256 pools = _ids.length;
        for (uint256 i; i < pools;) {
            receivedPoolTokens.push(uint64(_ids[i]));
            unchecked {
                ++i;
            }
        }

        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }

    /// @dev Example placeholder function for executing logic that will send meta-tokens (ERC20) to this contract.
    function receive_meta_tokens() public {}

    /// @dev Example placeholder function for logic to execute after removing all liquidity.
    function use_underlying_tokens() public {}
}
