// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title IBlockEstate
 * @dev Interface for the BlockEstate token contract
 */
interface IBlockEstate {
    // Custom Errors
    error TradingNotStarted();
    error ExceedsMaxSupply();
    error NotAuthorized();
    error NotSeller();
    error InvalidAmount();
    error InvalidETHAmount();
    error ETHNotAccepted();
    error NoTokensExist();
    error InvalidQuoteAsset();
    error InvalidStartTimestamp();
    error InvalidArrayLengths();
    error ZeroAddress();

    // Events
    event TokensMinted(address indexed to, uint256 indexed id, uint256 amount);
    event TokensBurned(address indexed from, uint256 indexed id, uint256 amount);
    event FundsDistributed(uint256 indexed id, uint256 totalAmount, uint256 perTokenAmount);
    event SellerUpdated(address indexed seller);

    // Functions
    function mint(address to, uint256 id, uint256 amount) external payable;
    function burn(address from, uint256 id, uint256 amount) external;
    function distributeFunds(uint256 id, uint256 amount) external;
    function setSeller(address newSeller) external;
    function seller() external view returns (address);
    function totalSupply(uint256 id) external view returns (uint256);
    function uri(uint256 id) external view returns (string memory);
    function quoteAsset() external view returns (address);
    function startTimestamp() external view returns (uint256);
    function tokenPrices(uint256 id) external view returns (uint256);
    function maxSupply(uint256 id) external view returns (uint256);
    function totalDistributed(uint256 id) external view returns (uint256);
}
