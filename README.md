# 🎲 Loteria - Decentralized Raffle DApp

A modern, decentralized lottery platform built on Ethereum that combines smart contracts with a sleek React frontend. Create and participate in transparent, verifiably random raffles powered by Chainlink VRF.

![Loteria Frontend](https://github.com/user-attachments/assets/581e0f0b-e99f-4907-a140-8ed8b69920ff)

## ✨ Features

- **🔐 Decentralized & Trustless**: All lottery logic runs on smart contracts
- **🎯 Verifiable Randomness**: Uses Chainlink VRF for provably fair winner selection
- **💰 Multiple Payment Options**: Support for ETH and ERC-20 tokens
- **🎨 Modern UI**: Clean, responsive interface built with React and TailwindCSS
- **👥 Open & Private Lotteries**: Create public lotteries or invite-only raffles
- **📊 Real-time Updates**: Live participant tracking and winner announcements
- **🔍 Transparent**: All transactions and results are publicly verifiable on-chain

## 🏗️ Architecture

### Smart Contracts
- **LotteryFactory**: Deploys and manages lottery contracts, handles VRF coordination
- **LotteryOpen**: Public lotteries where anyone can participate by buying tickets
- **LotteryClosed**: Private/invite-only lotteries with controlled participant lists
- **LotteryBase**: Shared functionality and VRF integration for all lottery types

### Frontend
- **React + TypeScript**: Modern frontend framework with type safety
- **Wagmi + Viem**: Web3 integration for wallet connections and contract interactions
- **TailwindCSS**: Utility-first CSS framework for responsive design
- **React Query**: Data fetching and caching for optimal performance

## 🚀 Quick Start

### Prerequisites

- [Node.js](https://nodejs.org/) (v18 or higher)
- [Foundry](https://book.getfoundry.sh/getting-started/installation) for smart contract development
- A Web3 wallet (MetaMask, WalletConnect, etc.)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/alva-p/Raffle-dapp.git
   cd Raffle-dapp
   ```

2. **Install smart contract dependencies**
   ```bash
   cd contracts
   forge install
   ```

3. **Install frontend dependencies**
   ```bash
   cd ../loteria-frontend
   npm install
   ```

### Development Setup

#### Smart Contracts

1. **Compile contracts**
   ```bash
   cd contracts
   forge build
   ```

2. **Run tests**
   ```bash
   forge test
   ```

3. **Deploy locally (optional)**
   ```bash
   # Start local blockchain
   anvil
   
   # In another terminal, deploy contracts
   forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key <PRIVATE_KEY> --broadcast
   ```

#### Frontend

1. **Start development server**
   ```bash
   cd loteria-frontend
   npm run dev
   ```

2. **Open your browser**
   Navigate to `http://localhost:5173`

3. **Connect your wallet**
   Click "Connect Wallet" and follow the prompts

## 🎮 Usage

### Creating a Lottery

1. Connect your Web3 wallet
2. Click "Create Lottery" on the homepage
3. Configure your lottery:
   - Set ticket price (ETH or ERC-20 token)
   - Choose number of winners
   - Set participant limits (for open lotteries)
4. Deploy your lottery contract
5. Share the lottery address with participants

### Joining a Lottery

1. Connect your Web3 wallet
2. Click "Explore Lotteries" or enter a lottery address
3. Review lottery details (ticket price, participants, etc.)
4. Purchase tickets by sending the required payment
5. Wait for the drawing and check if you won!

## 📋 Smart Contract Details

### LotteryFactory.sol
- **Purpose**: Central factory for creating and managing lottery contracts
- **Key Functions**:
  - `createLotteryOpen()`: Deploy new public lottery
  - `requestRandomness()`: Request VRF randomness for drawings
  - `fulfillRandomWords()`: Handle VRF callback with random numbers

### LotteryOpen.sol
- **Purpose**: Public lottery where anyone can participate
- **Key Functions**:
  - `enter()`: Join lottery with ETH payment
  - `enterWithToken()`: Join lottery with ERC-20 token payment
  - `drawWinners()`: Initiate winner selection process

### LotteryBase.sol
- **Purpose**: Abstract base contract with shared lottery functionality
- **Features**:
  - VRF integration for randomness
  - State management (Pending, Open, Drawing, Completed)
  - Participant and winner tracking

## 🔧 Configuration

### Environment Variables

#### Frontend Configuration
Create a `.env` file in the root directory:
```env
# Frontend RPC URL (optional - defaults to public Sepolia RPC)
VITE_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
```

#### Smart Contract Configuration
Create a `.env` file in the `contracts/` directory:
```env
# Network Configuration
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
PRIVATE_KEY=0x...your_private_key_here

# Chainlink VRF Configuration (Sepolia testnet values)
VRF_COORDINATOR=0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
SUBSCRIPTION_ID=your_subscription_id
KEY_HASH=0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c
VRF_MIN_CONF=3
VRF_CB_GAS=500000
```

> ⚠️ **Security Warning**: Never commit private keys to version control. The `.env` files should be added to `.gitignore` and private keys should only be used for testnet development.

### Frontend Configuration

The frontend automatically detects your wallet's network. Supported networks:
- Ethereum Mainnet
- Sepolia Testnet
- Polygon
- Other EVM-compatible chains

## 🧪 Testing

### Smart Contract Tests
```bash
cd contracts
forge test -vvv
```

### Frontend Tests
```bash
cd loteria-frontend
npm test
```

## 🚀 Deployment

### Smart Contracts

1. **Configure deployment script**
   Update `contracts/script/Deploy.s.sol` with your parameters

2. **Deploy to testnet**
   ```bash
   forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
   ```

### Frontend

1. **Build for production**
   ```bash
   cd loteria-frontend
   npm run build
   ```

2. **Deploy to hosting service**
   - Vercel: `vercel --prod`
   - Netlify: Drag the `dist` folder to Netlify
   - IPFS: Upload `dist` folder to IPFS

## 🛠️ Development

### Project Structure
```
Raffle-dapp/
├── contracts/              # Smart contracts (Foundry project)
│   ├── src/                # Contract source code
│   ├── test/               # Contract tests
│   ├── script/             # Deployment scripts
│   └── foundry.toml        # Foundry configuration
├── loteria-frontend/       # React frontend
│   ├── src/                # Frontend source code
│   ├── public/             # Static assets
│   └── package.json        # Frontend dependencies
└── README.md               # This file
```

### Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style

- **Smart Contracts**: Follow Solidity style guide
- **Frontend**: ESLint + Prettier configuration included
- **Commits**: Use conventional commit messages

## 🔐 Security

- Smart contracts use OpenZeppelin libraries for security
- VRF ensures verifiable randomness
- All lottery funds are held in escrow until winners are drawn
- Contract ownership is transferred to deployer for governance

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

- **Issues**: [GitHub Issues](https://github.com/alva-p/Raffle-dapp/issues)
- **Discussions**: [GitHub Discussions](https://github.com/alva-p/Raffle-dapp/discussions)

## 🙏 Acknowledgments

- [OpenZeppelin](https://openzeppelin.com/) for secure smart contract libraries
- [Chainlink](https://chain.link/) for verifiable randomness (VRF)
- [Foundry](https://book.getfoundry.sh/) for development framework
- [Wagmi](https://wagmi.sh/) for Web3 React hooks

---

**Built with ❤️ for the decentralized future**