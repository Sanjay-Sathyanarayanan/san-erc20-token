// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {SanToken} from "../src/SanToken.sol";
import {DeploySanToken} from "../script/DeploySanToken.s.sol";

contract SanTokenTest is Test {
    uint256 public constant initialBalance = 1000 ether;
    SanToken token;
    DeploySanToken deployer;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        deployer = new DeploySanToken();
        token = deployer.run();

        // Mint tokens to Alice
        vm.prank(msg.sender);
        token.transfer(alice, initialBalance);
    }

    /// @notice Test a successful transfer
    function test_Transfer() public {
        assertEq(token.balanceOf(alice), initialBalance);
    }

    /// @notice Test a successful approval and transferFrom
    function test_Allowance() public {
        uint256 transferAmount = 1 ether;

        // Alice approves Bob to spend 1 ether on her behalf
        vm.prank(alice);
        token.approve(bob, transferAmount);

        // Bob transfers 1 ether from Alice's account to his own
        vm.prank(bob);
        token.transferFrom(alice, bob, transferAmount);

        // Verify balances
        assertEq(token.balanceOf(bob), transferAmount);
        assertEq(token.allowance(alice, bob), 0); // Allowance should be used up
    }

    /// @notice Test transfer to zero address should revert
    function test_RevertWhen_TransferToZeroAddress() public {
        uint256 amount = 1 ether;

        vm.prank(alice);
        vm.expectRevert(); // Expect a revert due to invalid address
        token.transfer(address(0), amount);
    }

    /// @notice Test insufficient balance transfer should revert
    function test_RevertWhen_Transfer_InsufficientBalance() public {
        uint256 amount = 2000 ether; // More than Alice's balance

        vm.prank(alice);
        vm.expectRevert(); // Expect a revert due to insufficient funds
        token.transfer(bob, amount);
    }

    /// @notice Test transferFrom with insufficient allowance should revert
    function test_RevertWhen_TransferFrom_InsufficientAllowance() public {
        uint256 transferAmount = 10 ether; // More than approved amount

        vm.prank(alice);
        token.approve(bob, 1 ether); // Approve only 1 ether

        vm.prank(bob);
        vm.expectRevert(); // Expect a revert due to insufficient allowance
        token.transferFrom(alice, bob, transferAmount);
    }

    /// @notice Test approving zero address should revert
    function test_RevertWhen_ApproveToZeroAddress() public {
        vm.prank(alice);
        vm.expectRevert(); // Expect a revert due to invalid address
        token.approve(address(0), 1 ether);
    }
}
