// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title Default
 * @dev Contract containing default test values and constants
 */
contract Default {
    /*//////////////////////////////////////////////////////////////
                            PROPERTY CONSTANTS
    //////////////////////////////////////////////////////////////*/

    // Property token IDs
    uint256 public constant ID_1 = 1;
    uint256 public constant ID_2 = 2;
    uint256 public constant ID_3 = 3;

    // Property token prices
    uint256 public constant PRICE_1 = 1 ether;
    uint256 public constant PRICE_2 = 2 ether;
    uint256 public constant PRICE_3 = 3 ether;

    // Property token supplies
    uint256 public constant SUPPLY_1 = 100;
    uint256 public constant SUPPLY_2 = 200;
    uint256 public constant SUPPLY_3 = 300;

    /*//////////////////////////////////////////////////////////////
                            QUOTE TOKEN CONSTANTS
    //////////////////////////////////////////////////////////////*/

    string public constant TOKEN_NAME = "Quote Token";
    string public constant TOKEN_SYMBOL = "QUOTE";
    uint8 public constant TOKEN_DECIMALS = 18;

    /*//////////////////////////////////////////////////////////////
                            TEST ENVIRONMENT
    //////////////////////////////////////////////////////////////*/

    // Time settings
    uint256 public constant ONE_DAY = 24 hours;
    uint256 public constant ONE_WEEK = 7 days;
    uint256 public constant ONE_MONTH = 30 days;

    // Balance settings
    uint256 public constant ONE_ETH = 1 ether;
    uint256 public constant INITIAL_ETH_BALANCE = 100 ether;
    uint256 public constant INITIAL_TOKEN_BALANCE = 1000 ether;

    // Metadata settings
    string public constant DEFAULT_URI = "ipfs://QmTest";
}
