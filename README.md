# StarkPulse Smart Contracts



This repository contains the smart contracts that power the StarkPulse platform, a decentralized crypto news aggregator and portfolio management system built on StarkNet.

## Overview

StarkPulse smart contracts provide the blockchain infrastructure for user authentication, portfolio tracking, transaction monitoring, and contract interactions. Built with Cairo, these contracts leverage StarkNet's Layer 2 scaling solution to deliver high-performance, secure, and cost-effective blockchain operations.

## Contract Architecture

The StarkPulse contract system consists of four main components:

1. **User Authentication** - Manages user profiles and secure authentication
2. **Portfolio Tracking** - Tracks user assets and portfolio performance
3. **Transaction Monitoring** - Records and monitors blockchain transactions
4. **Contract Interaction** - Provides a unified interface for contract operations

## Key Features

- **Secure User Authentication** 🔐: Wallet-based authentication with session management
- **Asset Tracking** 📊: Comprehensive tracking of tokens and NFTs
- **Portfolio Analytics** 📈: Historical portfolio value and performance metrics
- **Transaction History** 🔍: Detailed transaction recording and status tracking
- **Notification System** 🔔: Customizable notification preferences
- **Contract Registry** 🔄: Unified interface for contract interactions

## Directory Structure

```
contracts/
├── src/
│   ├── auth/
│   │   ├── user_auth.cairo
│   │   └── session_manager.cairo
│   ├── portfolio/
│   │   ├── portfolio_tracker.cairo
│   │   └── asset_manager.cairo
│   ├── transactions/
│   │   ├── transaction_monitor.cairo
│   │   └── notification_manager.cairo
│   ├── utils/
│   │   ├── contract_interaction.cairo
│   │   └── access_control.cairo
│   └── interfaces/
│       ├── i_user_auth.cairo
│       ├── i_portfolio_tracker.cairo
│       ├── i_transaction_monitor.cairo
│       └── i_contract_interaction.cairo
├── tests/
│   ├── auth/
│   │   ├── test_user_auth.cairo
│   │   └── test_session_manager.cairo
│   ├── portfolio/
│   │   ├── test_portfolio_tracker.cairo
│   │   └── test_asset_manager.cairo
│   ├── transactions/
│   │   ├── test_transaction_monitor.cairo
│   │   └── test_notification_manager.cairo
│   └── utils/
│       ├── test_contract_interaction.cairo
│       └── test_access_control.cairo
├── scripts/
│   ├── deploy.sh
│   ├── verify.sh
│   └── test.sh
├── deployments/
│   ├── mainnet/
│   │   └── addresses.json
│   └── testnet/
│       └── addresses.json
├── abis/
│   ├── UserAuth.json
│   ├── PortfolioTracker.json
│   ├── TransactionMonitor.json
│   └── ContractInteraction.json
├── Scarb.toml
├── README.md
└── .gitignore
```

## Contract Details

### UserAuth Contract

Handles user authentication and profile management:
- Profile creation and updates
- Session management
- Signature verification
- Nonce management for replay protection

### PortfolioTracker Contract

Manages user portfolio data:
- Asset addition, updates, and removal
- Portfolio snapshot creation
- Historical portfolio value tracking
- Support for both tokens and NFTs

### TransactionMonitor Contract

Records and monitors blockchain transactions:
- Transaction recording
- Status updates
- Notification preferences
- Transaction history retrieval

### ContractInteraction Contract

Provides a unified interface for contract operations:
- Contract registry
- Caller approval system
- Unified contract calling interface

## Getting Started

### Prerequisites

- [Scarb](https://docs.swmansion.com/scarb/) - Cairo package manager
- [StarkNet CLI](https://www.cairo-lang.org/docs/hello_starknet/index.html#installation) - StarkNet command-line interface
- [Node.js](https://nodejs.org/) - For deployment scripts

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Pulsefy/StarkPulse-Contracts.git
cd StarkPulse-Contracts
```

2. Install dependencies:
```bash
scarb install
```

3. Build the contracts:
```bash
scarb build
```

### Testing

Run the test suite:
```bash
scarb test
```

### Deployment

1. Configure deployment settings in `scripts/deploy.sh`

2. Deploy to testnet:
```bash
./scripts/deploy.sh testnet
```

3. Deploy to mainnet:
```bash
./scripts/deploy.sh mainnet
```

## Contract Interaction

The contracts can be interacted with using:

1. **StarkNet.js** - JavaScript library for frontend integration
2. **StarkNet CLI** - Command-line interface for direct interaction
3. **StarkPulse Backend API** - NestJS API for application integration

## Security

These contracts implement several security measures:

- Access control for sensitive operations
- Signature verification for authentication
- Nonce management for replay protection
- Event emission for transparency
- Comprehensive testing

## Contributing

We welcome contributions to StarkPulse contracts! Please follow these steps:

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## Maintainers

- Divineifed1 👨‍💻
- Cedarich 👨‍💻

---

<p align="center">
  Built with ❤️ by the StarkPulse Team
</p>
