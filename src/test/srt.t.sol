// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import {ISRT} from "../interface/ISRT.sol";
import {SRT20Minimal} from "../SRT20.sol";
import {SRT721Minimal} from "../SRT721.sol";
import {SRT1155Minimal} from "../SRT1155.sol";

contract TestRun is DSTest {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    Utilities internal utils;
    address payable[] internal users;

    function setUp() public {
        utils = new Utilities();
        users = utils.createUsers(5);
    }

    function testSRT20() public {
        address payable alice = users[0];
        // labels alice's address in call traces as "Alice [<address>]"
        vm.label(alice, "Alice");
        console.log("alice's address", alice);
        address payable bob = users[1];
        vm.label(bob, "Bob");

        vm.startPrank(alice);
        SRT20Minimal srt20 = new SRT20Minimal();
        uint256 amount = 10 ether;
        srt20.mint(alice, amount);
        vm.expectRevert(SRT20Minimal.TransferNotAllowed.selector);
        srt20.transfer(bob, amount);
        vm.warp(block.timestamp + 100);
        assertEq(srt20.affectOf(alice, 0), amount * 100);
        srt20.burn(alice, amount);
        assertEq(srt20.affectOf(alice, 0), amount * 100);

        // assertEq(type(ISRT).interfaceId, bytes4(0x00000001));
        vm.stopPrank();
    }

    function testSRT721() public {
        address payable alice = users[0];
        // labels alice's address in call traces as "Alice [<address>]"
        vm.label(alice, "Alice");
        console.log("alice's address", alice);
        address payable bob = users[1];
        vm.label(bob, "Bob");

        vm.startPrank(alice);
        SRT721Minimal srt721 = new SRT721Minimal();
        srt721.safeMint(alice, 1);
        vm.expectRevert(SRT721Minimal.TransferNotAllowed.selector);
        srt721.safeTransferFrom(alice, bob, 1);
        vm.warp(block.timestamp + 100);
        assertEq(srt721.affectOf(alice, 1), 100);
        srt721.burn(1);
        assertEq(srt721.affectOf(alice, 1), 100);

        // assertEq(type(ISRT).interfaceId, bytes4(0x00000001));
        vm.stopPrank();
    }

    function testSRT1155() public {
        address payable alice = users[0];
        // labels alice's address in call traces as "Alice [<address>]"
        vm.label(alice, "Alice");
        console.log("alice's address", alice);
        address payable bob = users[1];
        vm.label(bob, "Bob");

        uint256 amount = 10 ether;
        vm.startPrank(alice);
        SRT1155Minimal srt1155 = new SRT1155Minimal();
        bytes memory data;
        srt1155.mint(alice, 1, amount, data);

        vm.expectRevert(SRT1155Minimal.TransferNotAllowed.selector);
        srt1155.safeTransferFrom(alice, bob, 1, amount, data);
        vm.warp(block.timestamp + 100);
        assertEq(srt1155.affectOf(alice, 1), amount * 100);
        srt1155.burn(alice, 1, amount);
        assertEq(srt1155.affectOf(alice, 1), amount * 100);
        vm.stopPrank();
    }
}
