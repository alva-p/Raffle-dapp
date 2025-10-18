# Raffle / Lottery DApp (Ethereum + Chainlink VRF)

#### A decentralized raffle system with verifiable randomness via Chainlink VRF. Fully transparent lifecycle and automatic on-chain payouts.

## Live Frontend: https://raffle-dapp-five.vercel.app/

### Factory (Sepolia): 0x9dc217a2b06d55e1E3C913D0597bE3847Ab373CE

# Tech Stack: 
- Solidity ^0.8.24  
- React 18 
- TypeScript 5 
- Wagmi/Viem 
- Tailwind 
- Foundry
- Network: Ethereum Sepolia · 
- Chainlink VRF v2 (Subscription 12478)

## TL;DR (Too Long; Didn't Read)

- **Anyone can create a public raffle by setting a ticket price.**
- **Users buy tickets while the raffle is open.**
- **The creator closes the raffle to trigger a provably fair winner selection via VRF.**
- **The winner is paid automatically on-chain.**

# Table of Contents

## Architecture

## Addresses & Deployment

## User Stories

## Core Flows

## Key Features

## Install & Run

## Contract Configuration

## Security

## Tests & Coverage

## Limitations & Roadmap

## License & Author

## References

## Architecture

### Smart Contracts (Foundry):
```
├── LotteryFactoryV7.sol   # Deploys raffles and orchestrates VRF
├── LotteryOpenV4.sol      # Individual raffle instances
├── VRFManager.sol         # Chainlink VRF subscription/requests
└── EmergencyWithdraw.sol  # Controlled recovery escape hatches
```

# Frontend (React + TypeScript):

- ### Wagmi/Viem for on-chain calls

- ### Custom hooks for raffle state and events

- ### Tailwind UI with state filters and pagination


# Blockchain Integration:

- ### Chainlink VRF v2 with ~100k gas callback budget

- ### Factory pattern for consistent, cheaper deployments


## Lifecycle: Open → Drawing → Completed | Cancelled

## Addresses & Deployment

### Network: Sepolia

### Factory: 0x9dc217a2b06d55e1E3C913D0597bE3847Ab373CE

### VRF Subscription: 12478

### VRF Coordinator / Key Hash: configured in VRFManager.sol per network

## If you fork or redeploy, update these addresses in the frontend env and Foundry scripts.

# User Stories
### 1) As a Creator, I want to create a public raffle

Acceptance Criteria (Given/When/Then):

Given my wallet is connected, When I set a valid ticket price and confirm, Then the Factory deploys a new raffle in Open state.

Given a raffle is Open, When I close it, Then it moves to Drawing and requests randomness from VRF.

### 2) As a Player, I want to join by buying tickets

Given a raffle is Open, When I call buyTicket() with msg.value == ticketPrice, Then I’m registered as a participant and the transaction is visible on the explorer.

Given I send an incorrect amount, When I try to buy, Then the transaction reverts with a clear error.

### 3) As the System, I want a verifiable winner selection

Given a raffle in Drawing, When the VRF callback arrives, Then the contract deterministically picks one winner on-chain and sets the raffle to Completed.

### 4) As the Winner, I want to receive the pot automatically

Given I’m selected, When the callback executes, Then the pot is transferred to me in the same transaction (no manual steps).

### 5) As a Creator, I need emergency procedures

Given an external issue (e.g., unfunded VRF subscription), When I use an allowed emergency function, Then I can recover stuck funds under strict access control.

### 6) As an Auditor/Reviewer, I need full traceability

Given any raffle, When I inspect events and state, Then I can verify participants, state transitions, VRF requestId, and the final winner.

## Core Flows

- Create Raffle → Connect wallet → Set ticket price → Factory.createLottery() → new LotteryOpenV4 instance.

- Participate
Player calls buyTicket() with exact ticketPrice.

- Close & Draw
Creator calls close() → VRFManager.requestRandomWords() → state Drawing.

- VRF Callback
Coordinator calls fulfillRandomWords() → compute winning index → auto-payout → state Completed.

- Key Features

- Provably Fair Randomness: Chainlink VRF v2 with cryptographic proofs.

- Automatic Payouts: Winner receives the pot in the VRF callback.

- Factory Pattern: Lower deployment cost for new raffles.

- Productive UI: Filters by state (All/Open/Drawing/Completed/Cancelled), pagination, recent-first ordering.

- Wallet Compatibility: MetaMask and WalletConnect via Wagmi.

## Install & Run
### Prerequisites
- Node.js 18+

- Foundry (forge + cast)

- Wallet (MetaMask or compatible)

### Frontend
```
cd loteria-frontend
npm install
npm run dev
```

### Contracts
```
cd contracts
forge install
forge build
forge test
```

# Example deploy
```
forge script script/DeployV5.s.sol --rpc-url $SEPOLIA_RPC --broadcast --verify
```

## Contract Configuration

### Create an .env for Foundry and the frontend:

# Foundry / scripts
```
PRIVATE_KEY=0x...                 # test-only deploy key
SEPOLIA_RPC=https://...
ETHERSCAN_API_KEY=...
```

# Frontend
```
VITE_FACTORY_ADDRESS=0x9dc217a2b06d55e1E3C913D0597bE3847Ab373CE
VITE_NETWORK_ID=11155111
VITE_VRF_SUBSCRIPTION_ID=12478
```

### Best practice: commit a .env.example and add .env to .gitignore.

# Security

- ### Access Control: only the raffle creator can close/cancel that raffle.

- ### Strict State Guards: transitions enforced (Open → Drawing → Completed/Cancelled).

- ### Reentrancy Protection: applied to payment-sensitive paths.

- ### VRF Isolation: VRFManager separates subscription + callbacks.

- ### Emergency Functions: constrained and event-logged for auditability.

- ### Threat Model (high-level):

- ### Malicious inputs → explicit validation with informative require messages.

- ### VRF liveness → monitor LINK funding and operational alerts.

- ### Fund lockups → defined recovery paths gated by roles (optional timelocks).

# Tests & Coverage

- ### Unit Tests (Foundry):

- ### Factory deploy + raffle creation

- ### Ticket purchase + validation

- ### VRF integration (mock) + winner selection

- ### Emergency paths + invalid states

- ### Gas checks for callback budget

```
 Run:

forge test -vvv
```
- ### Limitations & Roadmap

- ### Current Limitations

- ### Single winner per raffle

- ### Manual closing by the creator

- ### Requires funded VRF subscription (LINK)

## Roadmap

### Private raffles with whitelists

### Multiple winners / prize tiers

### Time-boxed raffles (auto-close by deadline)

### Multi-chain support (Base, Abstract, Ronin EVM)

### Analytics dashboard (history, participation KPIs)

# License & Author

#License: MIT
#Author: @pimmpi_ — GitHub
 #· Twitter

# References

## Chainlink VRF v2: https://docs.chain.link/vrf/v2/introduction

## Foundry Book: https://book.getfoundry.sh/

## Wagmi: https://wagmi.sh/

## Tailwind CSS: https://tailwindcss.com/

## Extras (optional but recruiter-friendly)

## .env.example

# Foundry / scripts
```
PRIVATE_KEY=
SEPOLIA_RPC=
ETHERSCAN_API_KEY=
```

# Frontend
```
VITE_FACTORY_ADDRESS=
VITE_NETWORK_ID=11155111
VITE_VRF_SUBSCRIPTION_ID=
```

# Contributing

1. Fork the repo and create a feature branch.
2. Keep PRs small and focused (tests required for contracts).
3. Explain the rationale, gas impact, and UX impact.
4. Avoid committing secrets; use `.env` and `.env.example`.

## **Built By**

**@pimmpi_** | [GitHub](https://github.com/alva-p) | [Twitter](https://twitter.com/pimmpi_)

*Built for the web3 community*
