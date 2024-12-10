// SPDX-License-Identifier: MIT
/* solhint-disable var-name-mixedcase */
pragma solidity 0.8.25;

import { BaseTest } from "./Base.t.sol";
import { BlockEstate } from "../src/BlockEstate.sol";
import { Errors } from "../src/libraries/Error.sol";

contract BlockEstateFactoryTest is BaseTest {
    function test_WhitelistSeller() public {
        vm.startPrank(OWNER);
        address newSeller = makeAddr("newSeller");

        // Test whitelisting
        factory.setSeller(newSeller, true);
        assertTrue(factory.isWhitelistedSeller(newSeller));

        // Test removing from whitelist
        factory.setSeller(newSeller, false);
        assertFalse(factory.isWhitelistedSeller(newSeller));

        vm.stopPrank();
    }

    function test_OnlyOwnerCanWhitelist() public {
        vm.startPrank(USER1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OwnableUnauthorizedAccount.selector, USER1));
        factory.setSeller(USER2, true);
        vm.stopPrank();
    }

    function test_TokenizeProperty() public {
        vm.startPrank(SELLER);

        uint256 startTime = block.timestamp + ONE_DAY;
        uint256[] memory ids = new uint256[](3);
        ids[0] = ID_1;
        ids[1] = ID_2;
        ids[2] = ID_3;

        uint256[] memory prices = new uint256[](3);
        prices[0] = PRICE_1;
        prices[1] = PRICE_2;
        prices[2] = PRICE_3;

        uint256[] memory supplies = new uint256[](3);
        supplies[0] = SUPPLY_1;
        supplies[1] = SUPPLY_2;
        supplies[2] = SUPPLY_3;

        address estateAddress =
            factory.tokenizeProperty(DEFAULT_URI, address(quoteToken), ids, prices, supplies, startTime);

        assertTrue(factory.isValidEstate(estateAddress));
        assertEq(factory.getBlockEstates().length, 1);

        BlockEstate estate = BlockEstate(estateAddress);
        assertEq(estate.QUOTE_ASSET(), address(quoteToken));
        assertEq(estate.START_TIMESTAMP(), startTime);
        assertEq(estate.seller(), SELLER);

        vm.stopPrank();
    }

    function test_OnlyWhitelistedSellerCanTokenize() public {
        vm.startPrank(USER1);

        uint256[] memory ids = new uint256[](3);
        ids[0] = ID_1;
        ids[1] = ID_2;
        ids[2] = ID_3;

        uint256[] memory prices = new uint256[](3);
        prices[0] = PRICE_1;
        prices[1] = PRICE_2;
        prices[2] = PRICE_3;

        uint256[] memory supplies = new uint256[](3);
        supplies[0] = SUPPLY_1;
        supplies[1] = SUPPLY_2;
        supplies[2] = SUPPLY_3;

        vm.expectRevert(Errors.NotWhitelistedSeller.selector);
        factory.tokenizeProperty(DEFAULT_URI, address(quoteToken), ids, prices, supplies, block.timestamp + ONE_DAY);

        vm.stopPrank();
    }

    function test_InvalidArrayLengths() public {
        vm.startPrank(SELLER);

        uint256[] memory ids = new uint256[](3);
        ids[0] = ID_1;
        ids[1] = ID_2;
        ids[2] = ID_3;

        uint256[] memory invalidPrices = new uint256[](1);
        invalidPrices[0] = PRICE_1;

        uint256[] memory supplies = new uint256[](3);
        supplies[0] = SUPPLY_1;
        supplies[1] = SUPPLY_2;
        supplies[2] = SUPPLY_3;

        vm.expectRevert(Errors.InvalidArrayLengths.selector);
        factory.tokenizeProperty(
            DEFAULT_URI, address(quoteToken), ids, invalidPrices, supplies, block.timestamp + ONE_DAY
        );

        vm.stopPrank();
    }

    function test_InvalidStartTimestamp() public {
        vm.startPrank(SELLER);

        uint256[] memory ids = new uint256[](3);
        ids[0] = ID_1;
        ids[1] = ID_2;
        ids[2] = ID_3;

        uint256[] memory prices = new uint256[](3);
        prices[0] = PRICE_1;
        prices[1] = PRICE_2;
        prices[2] = PRICE_3;

        uint256[] memory supplies = new uint256[](3);
        supplies[0] = SUPPLY_1;
        supplies[1] = SUPPLY_2;
        supplies[2] = SUPPLY_3;

        vm.expectRevert(Errors.InvalidStartTimestamp.selector);
        factory.tokenizeProperty(
            DEFAULT_URI,
            address(quoteToken),
            ids,
            prices,
            supplies,
            block.timestamp // Current timestamp is invalid
        );

        vm.stopPrank();
    }

    function test_InvalidQuoteAsset() public {
        vm.startPrank(SELLER);

        uint256[] memory ids = new uint256[](3);
        ids[0] = ID_1;
        ids[1] = ID_2;
        ids[2] = ID_3;

        uint256[] memory prices = new uint256[](3);
        prices[0] = PRICE_1;
        prices[1] = PRICE_2;
        prices[2] = PRICE_3;

        uint256[] memory supplies = new uint256[](3);
        supplies[0] = SUPPLY_1;
        supplies[1] = SUPPLY_2;
        supplies[2] = SUPPLY_3;

        vm.expectRevert(Errors.InvalidQuoteAsset.selector);
        factory.tokenizeProperty(
            DEFAULT_URI,
            address(0), // Zero address is invalid
            ids,
            prices,
            supplies,
            block.timestamp + ONE_DAY
        );

        vm.stopPrank();
    }
}
