// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken public deployer;
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    uint256 public constant AMOUNT = 1000 * 10 ** 18;
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10 ** 18;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        // Fund users with tokens for testing
        vm.prank(address(deployer));
        ourToken.transfer(user1, AMOUNT * 2);
        ourToken.transfer(user2, AMOUNT);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testAllowance() public {
        vm.prank(user1);
        ourToken.approve(user2, AMOUNT);
        assertEq(ourToken.allowance(user1, user2), AMOUNT);
    }

    // function testIncreaseAllowance() public {
    //     vm.startPrank(user1);
    //     ourToken.approve(user2, AMOUNT);
    //     ourToken.increaseAllowance(user2, AMOUNT);
    //     assertEq(ourToken.allowance(user1, user2), AMOUNT * 2);
    //     vm.stopPrank();
    // }

    // function testDecreaseAllowance() public {
    //     vm.startPrank(user1);
    //     ourToken.approve(user2, AMOUNT * 2);
    //     ourToken.decreaseAllowance(user2, AMOUNT);
    //     assertEq(ourToken.allowance(user1, user2), AMOUNT);
    //     vm.stopPrank();
    // }

    // function testDecreaseAllowanceBelowZero() public {
    //     vm.startPrank(user1);
    //     ourToken.approve(user2, AMOUNT);
    //     vm.expectRevert();
    //     ourToken.decreaseAllowance(user2, AMOUNT + 1);
    //     vm.stopPrank();
    // }

    function testTransfer() public {
        uint256 balanceBefore = ourToken.balanceOf(user1);
        vm.prank(user1);
        ourToken.transfer(user2, AMOUNT);
        assertEq(ourToken.balanceOf(user1), balanceBefore - AMOUNT);
        assertEq(ourToken.balanceOf(user2), AMOUNT * 2);
    }

    function testTransferInsufficientBalance() public {
        vm.prank(user1);
        vm.expectRevert();
        ourToken.transfer(user2, AMOUNT * 3);
    }

    function testTransferFrom() public {
        vm.prank(user1);
        ourToken.approve(user2, AMOUNT);

        uint256 balanceBeforeSender = ourToken.balanceOf(user1);
        uint256 balanceBeforeReceiver = ourToken.balanceOf(user2);

        vm.prank(user2);
        ourToken.transferFrom(user1, user2, AMOUNT);

        assertEq(ourToken.balanceOf(user1), balanceBeforeSender - AMOUNT);
        assertEq(ourToken.balanceOf(user2), balanceBeforeReceiver + AMOUNT);
        assertEq(ourToken.allowance(user1, user2), 0);
    }

    function testTransferFromInsufficientAllowance() public {
        vm.prank(user1);
        ourToken.approve(user2, AMOUNT - 1);

        vm.prank(user2);
        vm.expectRevert();
        ourToken.transferFrom(user1, user2, AMOUNT);
    }

    function testTransferFromInsufficientBalance() public {
        vm.prank(user1);
        ourToken.approve(user2, AMOUNT * 3);

        vm.prank(user2);
        vm.expectRevert();
        ourToken.transferFrom(user1, user2, AMOUNT * 3);
    }

    function testTokenDetails() public {
        assertEq(ourToken.name(), "OurToken");
        assertEq(ourToken.symbol(), "OT");
        assertEq(ourToken.decimals(), 18);
    }

    function testTransferToZeroAddress() public {
        vm.prank(user1);
        vm.expectRevert();
        ourToken.transfer(address(0), AMOUNT);
    }

    function testTransferFromToZeroAddress() public {
        vm.prank(user1);
        ourToken.approve(user2, AMOUNT);

        vm.prank(user2);
        vm.expectRevert();
        ourToken.transferFrom(user1, address(0), AMOUNT);
    }

    function testApproveZeroAddress() public {
        vm.prank(user1);
        vm.expectRevert();
        ourToken.approve(address(0), AMOUNT);
    }
}
