// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ISRT} from "./interface/ISRT.sol";

contract SRT721Minimal is ERC721, ISRT {
    error TransferNotAllowed();

    mapping(address => uint256) lastUpdateMap;
    mapping(address => mapping(uint256 => uint256)) affectMap;

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
        uint256 affect = affectOf(to, tokenId);
        affectMap[to][tokenId] = affect;
        lastUpdateMap[to] = block.timestamp;
        _mint(to, tokenId);
        emit RecordAffect(msg.sender, to, block.timestamp, tokenId, affect);
    }

    function burn(uint256 tokenId) public {
        address from = ownerOf(tokenId);
        uint256 affect = affectOf(from, tokenId);
        affectMap[from][tokenId] = affect;
        lastUpdateMap[from] = block.timestamp;
        _update(address(0), tokenId, msg.sender);
        emit RecordAffect(msg.sender, from, block.timestamp, tokenId, affect);
    }

    function affectOf(address account, uint256 tokenId)
        public
        view
        returns (uint256 affect)
    {
        return
            affectMap[account][tokenId] +
            balanceOf(account) *
            (block.timestamp - lastUpdateMap[account]);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return
            interfaceId == type(ISRT).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
