// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {MyToken} from "../src/MyToken.sol";
import {Test} from "lib/forge-std/src/Test.sol";
import {RecipientMock} from "../test/mocks/RecepientMock.sol";

contract MyTokenTest is Test {
    MyToken public myToken;
    address public owner;
    address public addr1;
    address public addr2;
    uint256 public initialSupply = 1000;
    uint256 public initialBalance;

    function setUp() public {
        owner = address(this);
        addr1 = address(0x123);
        addr2 = address(0x456);
        myToken = new MyToken(initialSupply, "MyToken", "MTKN");
        initialBalance = myToken.balanceOf(owner);
    }

    function testDeployment() public {
        assertEq(myToken.name(), "MyToken");
        assertEq(myToken.symbol(), "MTKN");
        assertEq(myToken.totalSupply(), initialSupply * 10 ** uint256(myToken.decimals()));
        assertEq(myToken.balanceOf(owner), initialSupply * 10 ** uint256(myToken.decimals()));
    }

    function testTransfer() public {
        uint256 transferAmount = 1000;

        vm.prank(owner); 
        myToken.transfer(addr1, transferAmount);

        assertEq(myToken.balanceOf(addr1), transferAmount);
        assertEq(myToken.balanceOf(owner), initialBalance - transferAmount);
    }

    function testTransferFailsIfNotEnoughBalance() public {
        uint256 transferAmount = initialBalance + 1;

        vm.expectRevert("Insufficient balance");
        vm.prank(owner);
        myToken.transfer(addr1, transferAmount);
    }

    function testApproveAndTransferFrom() public {
        uint256 approvalAmount = 1000;
        uint256 transferAmount = 500;

        vm.prank(owner);
        myToken.approve(addr1, approvalAmount);

        assertEq(myToken.allowance(owner, addr1), approvalAmount);

        vm.prank(addr1);
        myToken.transferFrom(owner, addr2, transferAmount);

        assertEq(myToken.balanceOf(addr2), transferAmount);
        assertEq(myToken.balanceOf(owner), initialBalance - transferAmount);
    }

    function testApproveAndTransferFromFailsIfAllowanceExceeded() public {
        uint256 approvalAmount = 1000;
        uint256 transferAmount = 2000;

        vm.prank(owner);
        myToken.approve(addr1, approvalAmount);

        vm.expectRevert("Allowance exceeded");
        vm.prank(addr1);
        myToken.transferFrom(owner, addr2, transferAmount);
    }

    function testApproveAndCall() public {
        
        address recipient = address(new RecipientMock());

        uint256 approveAmount = 1000;
        bytes memory extraData = abi.encode(1234);

        vm.prank(owner);
        myToken.approveAndCall(recipient, approveAmount, extraData);

        
        RecipientMock recipientContract = RecipientMock(recipient);
        assertEq(recipientContract.lastApprovalSender(), owner);
        assertEq(recipientContract.lastApprovalValue(), approveAmount);
    }

    function testBurn() public {
        uint256 burnAmount = 1000;

        vm.prank(owner);
        myToken.burn(burnAmount);

        assertEq(myToken.balanceOf(owner), initialBalance - burnAmount);
        assertEq(myToken.totalSupply(), initialBalance - burnAmount);
    }

    function testBurnFailsIfNotEnoughBalance() public {
        uint256 burnAmount = initialBalance + 1;

        vm.expectRevert("Insufficient balance");
        vm.prank(owner);
        myToken.burn(burnAmount);
    }

    function testBurnFrom() public {
        uint256 burnAmount = 1000;
        vm.prank(owner);
        myToken.approve(addr1, burnAmount);

        vm.prank(addr1);
        myToken.burnFrom(owner, burnAmount);

        assertEq(myToken.balanceOf(owner), initialBalance - burnAmount);
        assertEq(myToken.totalSupply(), initialBalance - burnAmount);
    }

    function testBurnFromFailsIfAllowanceExceeded() public {
        uint256 burnAmount = 2000;
        vm.prank(owner);
        myToken.approve(addr1, 1000);

        vm.expectRevert("Allowance exceeded");
        vm.prank(addr1);
        myToken.burnFrom(owner, burnAmount);
    }

}