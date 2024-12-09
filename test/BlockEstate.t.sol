// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { BaseTest } from "./Base.t.sol";
import { BlockEstate } from "../src/BlockEstate.sol";
import { Error } from "./utils/Error.sol";

contract BlockEstateTest is BaseTest, Error {
    BlockEstate public estate;

    function setUp() public override {
        super.setUp();
        estate = createBlockEstate();
    }

    function test_Mint() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice);
        estate.mint(USER1, ID_1, amount);
        vm.stopPrank();

        assertEq(estate.balanceOf(USER1, ID_1), amount);
    }

    function test_MintBeforeStart() public {
        uint256 amount = 10;

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), amount * estate.tokenPrices(ID_1));
        vm.expectRevert(Error.TradingNotStarted.selector);
        estate.mint(USER1, ID_1, amount);
        vm.stopPrank();
    }

    function test_MintExceedsSupply() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = estate.maxSupply(ID_1) + 1;

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), amount * estate.tokenPrices(ID_1));
        vm.expectRevert(Error.ExceedsMaxSupply.selector);
        estate.mint(USER1, ID_1, amount);
        vm.stopPrank();
    }

    function test_Burn() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 burnAmount = 5;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice);
        estate.mint(USER1, ID_1, amount);
        estate.burn(USER1, ID_1, burnAmount);
        vm.stopPrank();

        assertEq(estate.balanceOf(USER1, ID_1), amount - burnAmount);
    }

    function test_BurnUnauthorized() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice);
        estate.mint(USER1, ID_1, amount);
        vm.stopPrank();

        vm.startPrank(USER2);
        vm.expectRevert(Error.NotAuthorized.selector);
        estate.burn(USER1, ID_1, amount);
        vm.stopPrank();
    }

    function test_DistributeFunds() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);
        uint256 distribution = 1 ether;

        // Mint tokens
        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice);
        estate.mint(USER1, ID_1, amount);
        vm.stopPrank();

        // Distribute funds
        vm.startPrank(SELLER);
        quoteToken.approve(address(estate), distribution);
        estate.distributeFunds(ID_1, distribution);
        vm.stopPrank();

        assertEq(estate.totalDistributed(ID_1), distribution);
    }

    function test_DistributeFundsUnauthorized() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);
        uint256 distribution = 1 ether;

        // Mint tokens
        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice);
        estate.mint(USER1, ID_1, amount);
        vm.stopPrank();

        // Try to distribute funds from non-seller
        vm.startPrank(USER2);
        quoteToken.approve(address(estate), distribution);
        vm.expectRevert(Error.NotSeller.selector);
        estate.distributeFunds(ID_1, distribution);
        vm.stopPrank();
    }

    function test_SetSeller() public {
        vm.startPrank(SELLER);
        estate.setSeller(USER1);
        vm.stopPrank();

        assertEq(estate.seller(), USER1);
    }

    function test_SetSellerUnauthorized() public {
        vm.startPrank(USER1);
        vm.expectRevert(Error.NotSeller.selector);
        estate.setSeller(USER2);
        vm.stopPrank();
    }
}
