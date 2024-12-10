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
git clone https://github.com/yourusername/block-estate.git
cd block-estate
```

2. Install dependencies:

```bash
forge install
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

1. Copy the environment file:

```bash
cp .env.example .env
```

2. Update `.env` with your configuration:

```
PRIVATE_KEY=your_private_key
RPC_URL=your_rpc_url
ETHERSCAN_API_KEY=your_etherscan_api_key
```

3. Deploy to network:

```bash
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --verify
```

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
