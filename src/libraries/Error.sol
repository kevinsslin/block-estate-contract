// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

library Errors {
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

    // BlockEstateFactory errors
    error OwnableUnauthorizedAccount(address caller);
    error NotWhitelistedSeller();
}
