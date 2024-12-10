// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title IBlockEstateFactory
 * @dev Interface for the BlockEstate factory contract
 */
interface IBlockEstateFactory {
    // Events
    event PropertyTokenized(
        address indexed estate,
        string metadataUri,
        address indexed quoteAsset,
        uint256[] ids,
        uint256[] prices,
        uint256[] supplyAmounts
    );
    event SellerWhitelisted(address indexed seller, bool status);

    // Functions
    function setSeller(address seller, bool status) external;
    function tokenizeProperty(
        string calldata metadataUri_,
        address quoteAsset,
        uint256[] calldata ids,
        uint256[] calldata prices,
        uint256[] calldata supplyAmounts,
        uint256 startTimestamp
    )
        external
        returns (address);
    function getBlockEstates() external view returns (address[] memory);
    function isValidEstate(address estate) external view returns (bool);
    function isWhitelistedSeller(address seller) external view returns (bool);
}
