// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Soul Resonance Token
 * @notice Interface of SRT
 * Note: The ERC-165 identifier for this interface is 0xe55ab48f
 */
interface ISRT {
    /**
     * @dev Emitted when `account` mint or burn tokens indicates a change in trend
     */
    event RecordAffect(
        address issuer,
        address account,
        uint256 blockTime,
        uint256 tokenIdOrTag,
        uint256 affect
    );

    /**
     * @dev get `account` affect in token id or tag
     */
    function affectOf(address account, uint256 tokenIdOrTag)
        external
        view
        returns (uint256 affect);
}
