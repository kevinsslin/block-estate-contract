# BlockEstate - Tokenized Real Estate Platform

BlockEstate is a smart contract platform for tokenizing real estate properties using the ERC1155 standard. The platform
enables fractional ownership of real estate assets and facilitates fund distribution to token holders.

## Features

- Factory pattern for deploying property tokens
- ERC1155 multi-token standard
- Configurable token pricing and supply
- Support for both ETH and ERC20 tokens as payment
- Fund distribution mechanism for token holders

## Smart Contracts

1. `BlockEstateFactory.sol`: Factory contract for creating and managing property tokens
2. `BlockEstate.sol`: ERC1155-based contract representing individual properties

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation.html)
- [Node.js](https://nodejs.org/) (v16 or later)

## Installation

1. Clone the repository:

```bash
git clone https://github.com/kevinsslin/block-estate.git
cd block-estate
```

2. Install dependencies:

```bash
bun install
```

## Development

1. Build the contracts:

```bash
forge build
```

2. Run tests:

```bash
forge test
```

3. Run tests with gas reporting:

```bash
forge test --gas-report
```

## Deployment

The BlockEstate contract has been deployed on the BSC Testnet. You can view the deployed contract at the following address:

- [BlockEstate Contract on BSC Testnet](https://testnet.bscscan.com/address/0x53304a40a8701bd3634bb1a315347cfc9ea31e67)

### Deploying Your Own Instance

If you want to deploy your own instance of the BlockEstate contract, you can use the following command:

```bash
forge script script/Deploy.s.sol:Deploy \
--rpc-url $RPC_URL \
--chain 97 \
--verify \
--verifier-api-key $API_KEY_BSCSCAN \
--broadcast
```


### Configuration

Before deploying, ensure you have the following environment variables set in your `.env` file:

```
PRIVATE_KEY=your_private_key
API_KEY_BSCSCAN=your_bscscan_api_key
RPC_URL=your_rpc_url
```


### Steps to Deploy

1. **Set Environment Variables**: Ensure your `.env` file is correctly configured with your private key and BSCScan API key.

2. **Run the Deployment Script**: Use the command provided above to deploy the contract to the BSC Testnet.

3. **Verify the Contract**: The script will automatically verify the contract on BSCScan using your API key.

### Notes

- Ensure you have sufficient BNB in your wallet to cover gas fees for deployment.
- The `--broadcast` flag will execute the transaction on the network.
- The `--verify` flag will verify the contract on BSCScan, making the source code publicly available.

For any issues or questions, please refer to the [Foundry documentation](https://book.getfoundry.sh/) or contact the project maintainers.

## Usage

### Creating a New Property Token

1. Deploy the factory contract
2. Call `tokenizeProperty` with:
   - Metadata URI pointing to property details
   - Quote asset address (use zero address for ETH)
   - Token IDs array
   - Price array
   - Supply amounts array
   - Start timestamp

### Minting Tokens

1. Approve quote asset spending (if using ERC20)
2. Call `mint` on the BlockEstate contract with:
   - Recipient address
   - Token ID
   - Amount to mint

### Distributing Funds

1. Call `distributeFunds` with:
   - Token ID
   - Distribution amount

## Testing

The test suite includes:

- Factory deployment and property tokenization
- Token minting and burning
- Fund distribution
- Access control
- Edge cases and error conditions

Run specific test:

```bash
forge test --match-test test_TokenizeProperty -vv
```

## Security

- All functions use reentrancy guards
- Input validation for arrays and parameters
- Access control for sensitive operations
- Immutable state variables where appropriate

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
