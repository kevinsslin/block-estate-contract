// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { Test } from "forge-std/src/Test.sol";
import { BlockEstateFactory } from "../src/BlockEstateFactory.sol";
import { BlockEstate } from "../src/BlockEstate.sol";
import { MockERC20 } from "./mocks/MockERC20.sol";
import { Default } from "./utils/Default.sol";

/**
 * @title BaseTest
 * @dev Base contract for BlockEstate test suite
 */
contract BaseTest is Test, Default {
    // Test contracts
    BlockEstateFactory public factory;
    MockERC20 public quoteToken;

    // Actor addresses
    address public OWNER;
    address public SELLER;
    address public USER1;
    address public USER2;
    address public RANDOM;

    /**
     * @dev Setup function called before each test
     */
    function setUp() public virtual {
        // Setup actors
        OWNER = makeAddr("owner");
        SELLER = makeAddr("seller");
        USER1 = makeAddr("user1");
        USER2 = makeAddr("user2");
        RANDOM = makeAddr("random");

        // Deploy contracts
        vm.startPrank(OWNER);
        factory = new BlockEstateFactory();
        factory.setSeller(SELLER, true);
        vm.stopPrank();

        // Setup quote token
        quoteToken = new MockERC20(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS);

        // Deal initial balances
        vm.deal(USER1, INITIAL_ETH_BALANCE);
        vm.deal(USER2, INITIAL_ETH_BALANCE);
        deal(address(quoteToken), USER1, INITIAL_TOKEN_BALANCE);
        deal(address(quoteToken), USER2, INITIAL_TOKEN_BALANCE);
        deal(address(quoteToken), SELLER, INITIAL_TOKEN_BALANCE);
    }

    /**
     * @dev Helper to create a new BlockEstate instance
     */
    function createBlockEstate() public returns (BlockEstate) {
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

        vm.startPrank(SELLER);
        BlockEstate newEstate = BlockEstate(
            factory.tokenizeProperty(DEFAULT_URI, address(quoteToken), ids, prices, supplies, block.timestamp + ONE_DAY)
        );
        vm.stopPrank();
        return newEstate;
    }

    /**
     * @dev Helper to approve token spending
     */
    function approveTokens(address spender, uint256 amount) public {
        vm.startPrank(USER1);
        quoteToken.approve(spender, amount);
        vm.stopPrank();

        vm.startPrank(USER2);
        quoteToken.approve(spender, amount);
        vm.stopPrank();

        vm.startPrank(SELLER);
        quoteToken.approve(spender, amount);
        vm.stopPrank();
    }
}
