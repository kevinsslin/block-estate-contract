// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IBlockEstate } from "./interfaces/IBlockEstate.sol";
import { Errors } from "./libraries/Error.sol";

/**
 * @title BlockEstate
 * @notice ERC1155 token representing tokenized real estate with fund distribution capabilities
 * @dev Implements IBlockEstate interface for property tokenization and management
 */
contract BlockEstate is IBlockEstate, ERC1155, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice URI for token metadata
    string public metadataUri;

    /// @notice Token used for pricing and payments
    address public immutable QUOTE_ASSET;

    /// @notice Mapping of token ID to its price
    mapping(uint256 tokenId => uint256 price) public tokenPrices;

    /// @notice Mapping of token ID to its maximum supply
    mapping(uint256 tokenId => uint256 supply) public maxSupply;

    /// @notice Timestamp when token trading starts
    uint256 public immutable START_TIMESTAMP;

    /// @notice Mapping of token ID to total funds distributed
    mapping(uint256 tokenId => uint256 amount) public totalDistributed;

    /// @notice Mapping of token ID to current total supply
    mapping(uint256 tokenId => uint256 supply) private _totalSupply;

    /// @notice Address of the property seller
    address public seller;

    /// @notice Array to store all token IDs
    uint256[] public allTokenIds;

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Ensures caller is the seller
     */
    modifier onlySeller() {
        if (msg.sender != seller) revert Errors.NotSeller();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Initializes the BlockEstate token
     * @param metadataUri_ URI pointing to the metadata of the property
     * @param quoteAsset_ Token used for pricing (address(0) for ETH)
     * @param ids_ Array of token IDs to initialize
     * @param prices_ Array of prices for each token ID
     * @param supplyAmounts_ Array of maximum supply for each token ID
     * @param startTimestamp_ Timestamp when token trading starts
     * @param seller_ Address of the property seller
     */
    constructor(
        string memory metadataUri_,
        address quoteAsset_,
        uint256[] memory ids_,
        uint256[] memory prices_,
        uint256[] memory supplyAmounts_,
        uint256 startTimestamp_,
        address seller_
    )
        ERC1155(metadataUri_)
    {
        if (quoteAsset_ == address(0)) revert Errors.InvalidQuoteAsset();
        if (startTimestamp_ <= block.timestamp) revert Errors.InvalidStartTimestamp();
        if (ids_.length != prices_.length || prices_.length != supplyAmounts_.length) {
            revert Errors.InvalidArrayLengths();
        }
        if (seller_ == address(0)) revert Errors.ZeroAddress();

        metadataUri = metadataUri_;
        QUOTE_ASSET = quoteAsset_;
        START_TIMESTAMP = startTimestamp_;
        seller = seller_;

        for (uint256 i = 0; i < ids_.length; i++) {
            if (prices_[i] == 0) revert Errors.InvalidAmount();
            if (supplyAmounts_[i] == 0) revert Errors.InvalidAmount();
            tokenPrices[ids_[i]] = prices_[i];
            maxSupply[ids_[i]] = supplyAmounts_[i];
            _totalSupply[ids_[i]] = 0;
            allTokenIds.push(ids_[i]); // Store token ID in array
        }

        emit SellerUpdated(seller_);
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Updates the seller address
     * @param newSeller New seller address
     */
    function setSeller(address newSeller) external onlySeller {
        if (newSeller == address(0)) revert Errors.ZeroAddress();
        seller = newSeller;
        emit SellerUpdated(newSeller);
    }

    /**
     * @notice Mints new tokens
     * @param to Recipient address
     * @param id Token ID to mint
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 id, uint256 amount) external payable nonReentrant {
        if (block.timestamp < START_TIMESTAMP) revert Errors.TradingNotStarted();
        if (amount == 0) revert Errors.InvalidAmount();
        if (_totalSupply[id] + amount > maxSupply[id]) revert Errors.ExceedsMaxSupply();

        uint256 totalPrice = amount * tokenPrices[id];
        if (QUOTE_ASSET == address(0)) {
            if (msg.value != totalPrice) revert Errors.InvalidETHAmount();
        } else {
            if (msg.value != 0) revert Errors.ETHNotAccepted();
            IERC20(QUOTE_ASSET).safeTransferFrom(msg.sender, address(this), totalPrice);
        }

        _totalSupply[id] += amount;
        _mint(to, id, amount, "");
        emit TokensMinted(to, id, amount);
    }

    /**
     * @notice Burns tokens
     * @param from Address to burn from
     * @param id Token ID to burn
     * @param amount Amount of tokens to burn
     */
    function burn(address from, uint256 id, uint256 amount) external nonReentrant {
        if (amount == 0) revert Errors.InvalidAmount();
        if (from != msg.sender && !isApprovedForAll(from, msg.sender)) {
            revert Errors.NotAuthorized();
        }

        _totalSupply[id] -= amount;
        _burn(from, id, amount);
        emit TokensBurned(from, id, amount);
    }

    /**
     * @notice Distributes funds to token holders
     * @param id Token ID to distribute funds for
     * @param amount Amount of funds to distribute
     */
    function distributeFunds(uint256 id, uint256 amount) external nonReentrant onlySeller {
        if (amount == 0) revert Errors.InvalidAmount();
        uint256 totalSupply_ = totalSupply(id);
        if (totalSupply_ == 0) revert Errors.NoTokensExist();

        IERC20(QUOTE_ASSET).safeTransferFrom(msg.sender, address(this), amount);

        uint256 perTokenAmount = amount / totalSupply_;
        totalDistributed[id] += amount;

        emit FundsDistributed(id, amount, perTokenAmount);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Gets total supply for a token ID
     * @param id Token ID to query
     * @return Current total supply
     */
    function totalSupply(uint256 id) public view returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @notice Gets the metadata URI for a token
     * @return Token metadata URI
     */
    function uri(uint256) public view virtual override(ERC1155, IBlockEstate) returns (string memory) {
        return metadataUri;
    }

    /**
     * @notice Gets the quote asset address
     * @return Address of the quote asset
     */
    function quoteAsset() external view override returns (address) {
        return QUOTE_ASSET;
    }

    /**
     * @notice Gets the start timestamp
     * @return Timestamp when token trading starts
     */
    function startTimestamp() external view override returns (uint256) {
        return START_TIMESTAMP;
    }

    /**
     * @notice Gets all token IDs
     * @return Array of all token IDs
     */
    function getAllTokenIds() external view returns (uint256[] memory) {
        return allTokenIds;
    }
}
