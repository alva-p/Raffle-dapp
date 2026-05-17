# Raffle / Lottery DApp

A decentralized smart contract lottery application, utilizing Chainlink VRF for provably fair random selection. The platform enables transparent on-chain ticket purchases, verifiable winner selection, and automatic prize distribution, all powered by Ethereum smart contracts.

## Demo

- Live frontend on Vercel: https://raffle.alva-p.xyz/

## Deployed Contracts

- Factory Contract (Ethereum Sepolia): `0x9dc217a2b06d55e1E3C913D0597bE3847Ab373CE`

---

## Technologies & Badges

- **Solidity** (Ethereum smart contracts)
- **Chainlink VRF v2** (on-chain randomness)
- **React 18 + TypeScript 5** (UI)
- **Wagmi, Viem** (Web3 integration)
- **Tailwind CSS** (Styling)
- **Foundry** (Contract development/testing)
- **Ethereum Sepolia Testnet**

---

## Overview

This DApp allows any user to create and participate in public lotteries by purchasing tickets on chain. Once the lottery is closed, Chainlink VRF is triggered to ensure transparent, cryptographically verifiable winner selection. The payout is transferred automatically to the winner in a trustless and auditable process.

### Main Flow

1. **Lottery Creation:** Authorized users may create new lotteries.
2. **Ticket Purchase:** Participants buy tickets while the lottery is open.
3. **Closing & Draw:** The lottery is closed, and Chainlink VRF requests a random winner.
4. **Winner Selection:** The contract selects the winner based on the VRF result.
5. **Prize Distribution:** The pot is transferred automatically to the winner.

### Features

- Full on-chain and audit-friendly transparency.
- Cryptographically secure, unbiased winner selection.
- Factory pattern for contract deployment efficiency.
- Simple and intuitive UI for both users and admins.
- MetaMask and WalletConnect compatibility.

---

## Local Development

### Requirements

- Node.js 18+
- Foundry (for Solidity contracts)
- MetaMask (or compatible wallet)

### Frontend

```bash
git clone https://github.com/alva-p/Raffle-dapp.git
cd loteria-frontend
npm install
npm run dev
```

### Contracts

```bash
cd contracts
forge install
forge build
forge test
```

_Deploy to Sepolia/testnet:_

```bash
forge script script/DeployV5.s.sol --rpc-url $SEPOLIA_RPC --broadcast --verify
```

_Configure environment variables in each package as documented._

---

## Security

- Strict access control: only the creator may close or cancel their raffle.
- Explicit state guards (no invalid transitions).
- Reentrancy protection for payment flows.
- VRF callbacks are isolated for safety.
- Emergency controls/op paths are strictly limited.
- Extensive unit testing for all smart contracts.

---

## Limitations & Roadmap

- Single winner per lottery
- Manual close by creator (no auto-close by deadline)
- Sepolia network only (for now)

**Roadmap:**  
- Multi-network and multiple winners support  
- Enhanced UX features and stats dashboard

---

## Contributing

Pull requests and suggestions are welcome. Please open an [issue](https://github.com/alva-p/Raffle-dapp/issues) or [PR](https://github.com/alva-p/Raffle-dapp/pulls) clearly describing your contribution. Unit tests are required for all contract changes.

---

## License

MIT

## Author

[alva-p](https://github.com/alva-p)
