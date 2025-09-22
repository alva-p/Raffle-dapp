# 🎲 Decentralized Lottery DApp

A fully decentralized lottery system built on Ethereum with Chainlink VRF for provably fair randomness. Create transparent lotteries where winners are selected automatically by verifiable random functions.

![Lottery DApp](https://img.shields.io/badge/Ethereum-Sepolia-blue) ![Solidity](https://img.shields.io/badge/Solidity-^0.8.24-blue) ![React](https://img.shields.io/badge/React-18-blue) ![TypeScript](https://img.shields.io/badge/TypeScript-5-blue) ![Chainlink](https://img.shields.io/badge/Chainlink-VRF%20V2-orange)

## 🚀 **Live Demo**
🌐 **Frontend:** [Live on v0](your-v0-url-here)  
⚡ **Smart Contracts:** Deployed on Sepolia Testnet  
📄 **Factory Contract:** [`0x9dc217a2b06d55e1E3C913D0597bE3847Ab373CE`](https://sepolia.etherscan.io/address/0x9dc217a2b06d55e1E3C913D0597bE3847Ab373CE)

---

## ✨ **Features**

### 🎯 **Core Functionality**
- **Create Public Lotteries** - Set ticket price and let anyone join
- **Transparent Randomness** - Chainlink VRF ensures fair winner selection
- **Automatic Payouts** - Winners receive funds automatically via VRF callback
- **Real-time Updates** - Live lottery state tracking and filtering
- **Multi-wallet Support** - MetaMask, WalletConnect, and more

### 🔧 **Technical Features**
- **Factory Pattern** - Efficient lottery deployment through factory contract
- **VRF Relay Pattern** - Optimized gas usage with 100K callback limit
- **State Management** - Comprehensive lottery lifecycle (Open → Drawing → Completed)
- **Emergency Functions** - Creator controls for lottery management
- **Responsive Design** - Works seamlessly on desktop and mobile

---

## 🏗️ **Architecture**

### **Smart Contracts**
```
├── LotteryFactoryV7.sol     # Main factory with VRF integration
├── LotteryOpenV4.sol        # Individual lottery instances  
├── VRFManager.sol           # Chainlink VRF subscription management
└── EmergencyWithdraw.sol    # Emergency recovery functions
```

### **Frontend Stack**
```
├── React 18 + TypeScript    # Modern UI framework
├── Wagmi + Viem             # Ethereum interaction library
├── Tailwind CSS             # Utility-first styling
└── Custom Hooks             # State management and blockchain interaction
```

### **Blockchain Integration**
- **Network:** Ethereum Sepolia Testnet
- **Oracle:** Chainlink VRF V2 (Subscription ID: 12478)
- **Gas Optimization:** 100K gas limit for reliable callbacks
- **Proxy Pattern:** Efficient contract deployment

---

##  **How It Works**

1. **Create Lottery** 🎫
   - Set ticket price (minimum 0.001 ETH)
   - Optional lottery name for identification
   - Factory deploys new lottery instance

2. **Players Join** 👥
   - Purchase tickets at set price
   - Unlimited participants (no cap)
   - Real-time participant tracking

3. **Random Selection** 🎲
   - Creator closes lottery to trigger drawing
   - Chainlink VRF provides verifiable randomness
   - Winner selected automatically on-chain

4. **Automatic Payout** 💰
   - Winner receives full prize pool instantly
   - Transaction confirmed on blockchain
   - Transparent and immutable results

---

## 🛠️ **Installation & Setup**

### **Prerequisites**
- Node.js 18+
- Foundry (for smart contracts)
- MetaMask or compatible wallet

### **Frontend Setup**
```bash
cd loteria-frontend
npm install
npm run dev
```

### **Smart Contract Development**
```bash
cd contracts
forge build
forge test
forge script script/DeployV5.s.sol --broadcast --rpc-url sepolia
```

---

## 📱 **User Interface**

### **Home Page**
- Clean landing with Web3 branding
- Connect wallet functionality
- Quick access to create/explore lotteries

### **Lottery Browser**
- **Sidebar Filtering:** All, Open, Drawing, Completed, Cancelled
- **Pagination:** 10 lotteries per page with navigation
- **Real-time Counts:** Live statistics for each category
- **Smart Ordering:** Most recent lotteries displayed first

### **Lottery Cards**
- **Visual State Indicators:** Clear status badges and colors
- **Key Information:** Price, participants, creator address
- **Action Buttons:** Join lottery or manage (if creator)
- **Progress Tracking:** Visual participant progress

---

## 🔐 **Security Features**

### **Smart Contract Security**
- **Access Control** - Only creators can manage their lotteries
- **State Validation** - Comprehensive state checks prevent invalid transitions  
- **Emergency Functions** - Creator escape hatches for edge cases
- **Reentrancy Protection** - Standard OpenZeppelin security patterns

### **VRF Security**
- **Subscription Model** - Pre-funded LINK for reliable randomness
- **Request Validation** - Only authorized contracts can request randomness
- **Callback Verification** - Ensures randomness comes from Chainlink

---

### **Test Coverage**
- ✅ Factory deployment and lottery creation
- ✅ Ticket purchasing and validation  
- ✅ VRF integration and winner selection
- ✅ Emergency functions and edge cases
- ✅ Gas optimization verification

---

## 🎯 **Technical Highlights**

### **Gas Optimization**
- **VRF Callback Limit:** Optimized to 100K gas for reliable execution
- **Factory Pattern:** Reduces deployment costs for new lotteries
- **Efficient State Management:** Minimal storage reads/writes

### **Developer Experience**
- **TypeScript Integration:** Full type safety across frontend
- **Custom Hooks:** Reusable blockchain interaction logic
- **Error Handling:** Comprehensive error states and user feedback
- **Real-time Updates:** Automatic UI updates on blockchain state changes

### **Scalability Considerations**
- **Pagination System:** Handles large numbers of lotteries efficiently
- **Filter Architecture:** Independent state management per filter
- **Modular Design:** Easy to extend with new lottery types

---

## 📈 **Future Enhancements**

### **Planned Features**
- 🔒 **Private Lotteries** - Whitelist-based participant management
- 🏆 **Multiple Winners** - Support for multiple prize tiers
- ⏰ **Time-based Lotteries** - Automatic closure after duration
- 🌐 **Multi-chain Support** - Deploy to additional networks

### **UI/UX Improvements**
- 📊 **Analytics Dashboard** - Historical lottery statistics
- 🔔 **Notifications** - Real-time updates for participants
- 🎨 **Themes** - Customizable visual appearance
- 📱 **Mobile App** - Native mobile application

---

## 🤝 **Contributing**

This project welcomes contributions! Please feel free to:
- Report bugs or suggest features
- Submit pull requests for improvements
- Share feedback on user experience

---

## 📄 **License**

MIT License - feel free to use this project as reference or starting point for your own DeFi applications.

---

## 👨‍💻 **Built By**

**@pimmpi_** | [GitHub](https://github.com/alva-p) | [Twitter](https://twitter.com/pimmpi_)

*Built with ❤️ for the web3 community*

---

## 🔗 **Links**

- 📚 [Chainlink VRF Documentation](https://docs.chain.link/vrf/v2/introduction)
- 🔧 [Foundry Documentation](https://book.getfoundry.sh/)
- ⚛️ [Wagmi Documentation](https://wagmi.sh/)
- 🎨 [Tailwind CSS](https://tailwindcss.com/)

---

*This project demonstrates advanced blockchain development skills including smart contract architecture, oracle integration, frontend development, and Web3 user experience design.*