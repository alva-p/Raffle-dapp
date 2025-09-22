// Contracts addresses
export const CONTRACT_ADDRESSES = {
  LOTTERY_FACTORY: "0x3887d63AebF99F7E27Bd52901d35F106d8a3BCA9", // Factory V5 - VRF DIRECTO (Gas optimizado)
} as const;

// LotteryOpenV2 ABI - Funciones completas de las loterias V2 optimizadas
export const LOTTERY_BASE_ABI = [
  {
    "type": "function",
    "name": "enter",
    "inputs": [],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "TICKET_PRICE",
    "inputs": [],
    "outputs": [{"type": "uint256"}],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getParticipants",
    "inputs": [],
    "outputs": [{"type": "address[]"}],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "lotteryState",
    "inputs": [],
    "outputs": [{"type": "uint8"}],
    "stateMutability": "view"
  },
  {
    "type": "function", 
    "name": "owner",
    "inputs": [],
    "outputs": [{"type": "address"}],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "closeLottery",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "emergencyDrawWinner",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "cancelLottery", 
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "claimPrize",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getWinners",
    "inputs": [],
    "outputs": [{"type": "address[]"}],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "importParticipants",
    "inputs": [{"type": "address[]", "name": "_participants"}],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "selectManualWinner",
    "inputs": [{"type": "uint256", "name": "winnerIndex"}],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getImportedParticipants",
    "inputs": [],
    "outputs": [{"type": "address[]"}],
    "stateMutability": "view"
  }
] as const;

// LotteryFactory ABI - Solo las funciones que necesitamos
export const LOTTERY_FACTORY_ABI = [
  {
    "type": "function",
    "name": "createLotteryOpen",
    "inputs": [
      {"type": "uint8", "name": "currency"},
      {"type": "address", "name": "token"},
      {"type": "uint256", "name": "ticketPrice"}
    ],
    "outputs": [{"type": "address"}],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "createLotteryPrivate",
    "inputs": [
      {"type": "uint8", "name": "currency"},
      {"type": "address", "name": "token"},
      {"type": "uint256", "name": "ticketPrice"}
    ],
    "outputs": [{"type": "address"}],
    "stateMutability": "nonpayable"
  },

  {
    "type": "function",
    "name": "getAllLotteries",
    "inputs": [],
    "outputs": [{"type": "address[]"}],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "owner",
    "inputs": [],
    "outputs": [{"type": "address"}],
    "stateMutability": "view"
  },
  {
    "type": "event",
    "name": "LotteryCreated",
    "inputs": [
      {"type": "address", "name": "lotteryAddress", "indexed": true},
      {"type": "address", "name": "creator", "indexed": true},
      {"type": "uint256", "name": "ticketPrice", "indexed": false},
      {"type": "string", "name": "name", "indexed": false}
    ]
  }
] as const;

// Enum values - Actualizados para LotteryOpenV2
export const LOTTERY_CURRENCY = {
  NATIVE: 0,  // Cambió de ETH a NATIVE
  ERC20: 1    // Cambió de TOKEN a ERC20
} as const;

// Estados actualizados para LotteryOpenV2
export const LOTTERY_STATE = {
  Open: 0,      // Cambió de ACTIVE a Open
  Drawing: 1,   // Estado Drawing cuando solicita VRF
  Completed: 2, // Estado final con ganador
  Cancelled: 3  // Estado cancelado
} as const;

export const LotteryState = {
  0: 'Open',
  1: 'Drawing', 
  2: 'Completed',
  3: 'Cancelled',
} as const;

export type LotteryStateType = typeof LOTTERY_STATE[keyof typeof LOTTERY_STATE];
