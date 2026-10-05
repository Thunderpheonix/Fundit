// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundIt} from "../src/FundIt.sol";

contract FundItTest is Test {
    FundIt public fundIt;
    address public user = makeAddr("user");

    function setUp() public {
        fundIt = new FundIt();
    }
    modifier createUserAndFund() {
        vm.deal(user, 1 ether);
        vm.startPrank(user);
        fundIt.fund{value: 1 ether}();
        _;
    }

    function testCanFund() public createUserAndFund {
        console.log("The value AddressToAmountFunded: ", fundIt.getaddressToAmountFunded(user));
        assertEq(fundIt.getaddressToAmountFunded(user), 1 ether);
        vm.stopPrank();
    }

    function testRevertEarlyWithdrawSpecificAmount() public createUserAndFund {
        vm.expectRevert(FundIt.TimeLockNotExpired.selector);
        fundIt.withdrawSpecific(1e17);
        vm.stopPrank();
    }

    function testWithdrawAfterOneMonth() public createUserAndFund {
        vm.warp(block.timestamp + 31 days);
        fundIt.withdrawSpecific(1e18);
        assertEq(fundIt.getaddressToAmountFunded(user), 0);
        vm.stopPrank();
    }

    function testWithdrawAfterOneMonthNotEnoughFund() public createUserAndFund {
        vm.warp(block.timestamp + 31 days);
        vm.expectRevert(FundIt.NotEnoughFund.selector);
        fundIt.withdrawSpecific(2e18);
        vm.stopPrank();
    }

    function testRevertFundWithZeroETH() public {
        vm.prank(user);
        vm.expectRevert(FundIt.MustSendETH.selector);
        fundIt.fund{value: 0}();
    }

    function testRevertWithdrawZero() public createUserAndFund {
        vm.warp(block.timestamp + 31 days);
        vm.expectRevert(FundIt.WithdrawAmountZero.selector);
        fundIt.withdrawSpecific(0);
        vm.stopPrank();
    }

    function testFirstDepositTimeNotChanged() public createUserAndFund {
        uint256 firstDepositTime = fundIt.getFirstDepositTime(user);
        vm.warp(block.timestamp + 15 days);
        vm.deal(user, 1 ether);

        fundIt.fund{value: 1 ether}();
        assertEq(fundIt.getFirstDepositTime(user), firstDepositTime);
        assertEq(fundIt.getaddressToAmountFunded(user), 2 ether);
    }
}
