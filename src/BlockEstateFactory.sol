// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { BlockEstate } from "./BlockEstate.sol";
import { IBlockEstateFactory } from "./interfaces/IBlockEstateFactory.sol";
import { Errors } from "./libraries/Error.sol";

/**
 * @title BlockEstateFactory
 * @dev Factory contract for creating and managing BlockEstate instances
 */
contract BlockEstateFactory is IBlockEstateFactory, Ownable {
    // State Variables
    address[] public deployedEstates;
    mapping(address estate => bool isValid) public isValidEstate;
    mapping(address seller => bool isWhitelisted) public isWhitelistedSeller;

    /**
     * @dev Constructor that sets up the owner
     */
    constructor(address owner) Ownable(owner) { }

    /**
     * @dev Modifier to check if sender is whitelisted seller
     */
    modifier onlyWhitelistedSeller() {
        if (!isWhitelistedSeller[msg.sender]) revert Errors.NotWhitelistedSeller();
        _;
    }

    /**
     * @dev Sets seller status in whitelist
     * @param seller Address of the seller
     * @param status Whitelist status to set
     */
    function setSeller(address seller, bool status) external onlyOwner {
        if (seller == address(0)) revert Errors.ZeroAddress();
        isWhitelistedSeller[seller] = status;
        emit SellerWhitelisted(seller, status);
    }

    /**
     * @dev Creates a new BlockEstate contract
     * @param metadataUri_ URI pointing to the metadata of the property
     * @param quoteAsset The address of the token used for pricing
     * @param ids Array of unique token IDs
     * @param prices Array of token prices corresponding to each ID
     * @param supplyAmounts Array of supply caps for each token ID
     * @param startTimestamp Timestamp when token trading starts
     */
    function tokenizeProperty(
        string calldata metadataUri_,
        address quoteAsset,
        uint256[] calldata ids,
        uint256[] calldata prices,
        uint256[] calldata supplyAmounts,
        uint256 startTimestamp
    )
        external
        onlyWhitelistedSeller
        returns (address)
    {
        if (ids.length != prices.length || prices.length != supplyAmounts.length) {
            revert Errors.InvalidArrayLengths();
        }
        if (startTimestamp <= block.timestamp) {
            revert Errors.InvalidStartTimestamp();
        }
        if (quoteAsset == address(0)) {
            revert Errors.InvalidQuoteAsset();
        }

        BlockEstate newEstate = new BlockEstate(
            metadataUri_,
            quoteAsset,
            ids,
            prices,
            supplyAmounts,
            startTimestamp,
            msg.sender // Set the seller as the deployer
        );

        address estateAddress = address(newEstate);
        deployedEstates.push(estateAddress);
        isValidEstate[estateAddress] = true;

        emit PropertyTokenized(estateAddress, metadataUri_, quoteAsset, ids, prices, supplyAmounts);

        return estateAddress;
    }

    /**
     * @dev Returns all deployed BlockEstate addresses
     */
    function getBlockEstates() external view returns (address[] memory) {
        return deployedEstates;
    }
}
