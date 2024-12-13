// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { BaseTest } from "./Base.t.sol";
import { BlockEstate } from "../src/BlockEstate.sol";
import { Errors } from "../src/libraries/Error.sol";

contract BlockEstateTest is BaseTest {
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

    function test_MintMultipleTokens() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount1 = 10;
        uint256 amount2 = 20;
        uint256 totalPrice1 = amount1 * estate.tokenPrices(ID_1);
        uint256 totalPrice2 = amount2 * estate.tokenPrices(ID_2);

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice1 + totalPrice2);
        estate.mint(USER1, ID_1, amount1);
        estate.mint(USER1, ID_2, amount2);
        vm.stopPrank();

        assertEq(estate.balanceOf(USER1, ID_1), amount1);
        assertEq(estate.balanceOf(USER1, ID_2), amount2);
    }

    function test_MintToOtherAddress() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice);
        estate.mint(USER2, ID_1, amount);
        vm.stopPrank();

        assertEq(estate.balanceOf(USER2, ID_1), amount);
        assertEq(estate.balanceOf(USER1, ID_1), 0);
    }

    function test_MintBeforeStart() public {
        uint256 amount = 10;

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), amount * estate.tokenPrices(ID_1));
        vm.expectRevert(Errors.TradingNotStarted.selector);
        estate.mint(USER1, ID_1, amount);
        vm.stopPrank();
    }

    function test_MintExceedsSupply() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = estate.maxSupply(ID_1) + 1;

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), amount * estate.tokenPrices(ID_1));
        vm.expectRevert(Errors.ExceedsMaxSupply.selector);
        estate.mint(USER1, ID_1, amount);
        vm.stopPrank();
    }

    function test_MintZeroAmount() public {
        vm.warp(block.timestamp + ONE_DAY);

        vm.startPrank(USER1);
        vm.expectRevert(Errors.InvalidAmount.selector);
        estate.mint(USER1, ID_1, 0);
        vm.stopPrank();
    }

    function test_MintWithoutApproval() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;

        vm.startPrank(USER1);
        vm.expectRevert();
        estate.mint(USER1, ID_1, amount);
        vm.stopPrank();
    }

    function test_MintWithInsufficientApproval() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice - 1);
        vm.expectRevert();
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
        assertEq(estate.totalSupply(ID_1), amount - burnAmount);
    }

    function test_BurnEntireBalance() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice);
        estate.mint(USER1, ID_1, amount);
        estate.burn(USER1, ID_1, amount);
        vm.stopPrank();

        assertEq(estate.balanceOf(USER1, ID_1), 0);
        assertEq(estate.totalSupply(ID_1), 0);
    }

    function test_BurnZeroAmount() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice);
        estate.mint(USER1, ID_1, amount);

        vm.expectRevert(Errors.InvalidAmount.selector);
        estate.burn(USER1, ID_1, 0);
        vm.stopPrank();
    }

    function test_BurnMoreThanBalance() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);

        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice);
        estate.mint(USER1, ID_1, amount);

        vm.expectRevert();
        estate.burn(USER1, ID_1, amount + 1);
        vm.stopPrank();
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
        vm.expectRevert(Errors.NotAuthorized.selector);
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

    function test_DistributeFundsMultipleTimes() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);
        uint256 distribution1 = 1 ether;
        uint256 distribution2 = 2 ether;

        // Mint tokens
        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice);
        estate.mint(USER1, ID_1, amount);
        vm.stopPrank();

        // First distribution
        vm.startPrank(SELLER);
        quoteToken.approve(address(estate), distribution1 + distribution2);
        estate.distributeFunds(ID_1, distribution1);

        // Second distribution
        estate.distributeFunds(ID_1, distribution2);
        vm.stopPrank();

        assertEq(estate.totalDistributed(ID_1), distribution1 + distribution2);
    }

    function test_DistributeFundsZeroAmount() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 amount = 10;
        uint256 totalPrice = amount * estate.tokenPrices(ID_1);

        // Mint tokens
        vm.startPrank(USER1);
        quoteToken.approve(address(estate), totalPrice);
        estate.mint(USER1, ID_1, amount);
        vm.stopPrank();

        // Try to distribute zero funds
        vm.startPrank(SELLER);
        vm.expectRevert(Errors.InvalidAmount.selector);
        estate.distributeFunds(ID_1, 0);
        vm.stopPrank();
    }

    function test_DistributeFundsWithoutTokens() public {
        vm.warp(block.timestamp + ONE_DAY);
        uint256 distribution = 1 ether;

        vm.startPrank(SELLER);
        quoteToken.approve(address(estate), distribution);
        vm.expectRevert(Errors.NoTokensExist.selector);
        estate.distributeFunds(ID_1, distribution);
        vm.stopPrank();
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
        vm.expectRevert(Errors.NotSeller.selector);
        estate.distributeFunds(ID_1, distribution);
        vm.stopPrank();
    }

    function test_SetSeller() public {
        vm.startPrank(SELLER);
        estate.setSeller(USER1);
        vm.stopPrank();

        assertEq(estate.seller(), USER1);
    }

    function test_SetSellerToZeroAddress() public {
        vm.startPrank(SELLER);
        vm.expectRevert(Errors.ZeroAddress.selector);
        estate.setSeller(address(0));
        vm.stopPrank();
    }

    function test_SetSellerUnauthorized() public {
        vm.startPrank(USER1);
        vm.expectRevert(Errors.NotSeller.selector);
        estate.setSeller(USER2);
        vm.stopPrank();
    }

    function test_GetAllTokenIds() public {
        uint256[] memory tokenIds = estate.getAllTokenIds();
        assertEq(tokenIds.length, 3);
        assertEq(tokenIds[0], ID_1);
        assertEq(tokenIds[1], ID_2);
        assertEq(tokenIds[2], ID_3);
    }

    function test_Uri() public {
        assertEq(estate.uri(ID_1), DEFAULT_URI);
        assertEq(estate.uri(ID_2), DEFAULT_URI);
        assertEq(estate.uri(ID_3), DEFAULT_URI);
    }
}
