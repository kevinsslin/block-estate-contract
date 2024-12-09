// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract Error {
    // BlockEstate errors
    error TradingNotStarted();
    error ExceedsMaxSupply();
    error NotAuthorized();
    error NotSeller();
    error InvalidQuoteAsset();
    error InvalidStartTimestamp();
    error InvalidArrayLengths();
    error ZeroAddress();
    error InvalidAmount();
    error InvalidETHAmount();
    error ETHNotAccepted();
    error NoTokensExist();
}
