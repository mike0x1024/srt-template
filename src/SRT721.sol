// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SRT721Minimal is ERC721 {
    error TransferNotAllowed();

    constructor() ERC721("Soul Resonance Token 721", "SRT721") {}

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = super._update(to, tokenId, auth);
        if (from != address(0) && to != address(0)) {
            revert TransferNotAllowed();
        }
        return from;
    }

    function safeMint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public {
        _update(address(0), tokenId, msg.sender);
    }

}
