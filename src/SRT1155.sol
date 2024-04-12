// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ISRT} from "./interface/ISRT.sol";

contract SRT1155Minimal is ERC1155, ISRT {
    error TransferNotAllowed();

    mapping(address => uint256) lastUpdateMap;
    mapping(address => mapping(uint256 => uint256)) affectMap;

    constructor() ERC1155("srt") {}

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override {
        if (from != address(0) && to != address(0)) {
            revert TransferNotAllowed();
        }
        super._update(from, to, ids, values);
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        uint256 affect = affectOf(to, id);
        affectMap[to][id] = affect;
        lastUpdateMap[to] = block.timestamp;
        _mint(to, id, amount, data);
        emit RecordAffect(msg.sender, to, block.timestamp, id, affect);
    }

    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) public {
        if (
            account != _msgSender() && !isApprovedForAll(account, _msgSender())
        ) {
            revert ERC1155MissingApprovalForAll(_msgSender(), account);
        }
        uint256 affect = affectOf(account, id);
        affectMap[account][id] = affect;
        lastUpdateMap[account] = block.timestamp;
        _burn(account, id, amount);
        emit RecordAffect(msg.sender, account, block.timestamp, id, affect);
    }

    function affectOf(address account, uint256 tokenId)
        public
        view
        returns (uint256 affect)
    {
        return
            affectMap[account][tokenId] +
            balanceOf(account, tokenId) *
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
