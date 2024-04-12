// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ISRT} from "./interface/ISRT.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract SRT20Minimal is ERC20, ISRT, ERC165 {
    error TransferNotAllowed();

    mapping(address => uint256) lastUpdateMap;
    mapping(address => uint256) affectMap;

    constructor() ERC20("Soul Resonance Token 20", "SRT20") {}

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (from != address(0) && to != address(0)) {
            revert TransferNotAllowed();
        }
        super._update(from, to, value);
    }

    function mint(address to, uint256 amount) public {
        uint256 affect = affectOf(to, 0);
        affectMap[to] = affect;
        lastUpdateMap[to] = block.timestamp;
        _mint(to, amount);
        emit RecordAffect(msg.sender, to, block.timestamp, 0, affect);
    }

    function burn(address from, uint256 amount) public {
        uint256 affect = affectOf(from, 0);
        affectMap[from] = affect;
        lastUpdateMap[from] = block.timestamp;
        _burn(from, amount);
        emit RecordAffect(msg.sender, from, block.timestamp, 0, affect);
    }

    function affectOf(address account, uint256)
        public
        view
        returns (uint256 affect)
    {
        return
            affectMap[account] +
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
