// 🎯 CONTRATOS MVP V7 UPDATED - VRF RELAY PATTERN 100K GAS
export const CONTRACT_ADDRESSES = {
  LOTTERY_FACTORY: "0x9dc217a2b06d55e1E3C913D0597bE3847Ab373CE", // Factory V7 Updated - 100K GAS LIMIT
} as const;

// 🎯 ABI SIMPLE PARA LOTERIAS V2
export const LOTTERY_BASE_ABI = [
  // ✅ PARTICIPAR
  {
    "type": "function",
    "name": "enter",
    "inputs": [],
    "outputs": [],
    "stateMutability": "payable"
  },
  
  // ✅ CERRAR Y SORTEAR
  {
    "type": "function",
    "name": "closeLottery", 
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  
  // ✅ EMERGENCY
  {
    "type": "function",
    "name": "emergencyDrawWinner",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  
  // ✅ CANCELAR
  {
    "type": "function",
    "name": "cancelLottery",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  
  // 📊 INFO FUNCTIONS
  {
    "type": "function",
    "name": "getParticipants",
    "inputs": [],
    "outputs": [{"type": "address[]"}],
    "stateMutability": "view"
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
    "name": "getParticipantCount",
    "inputs": [],
    "outputs": [{"type": "uint256"}],
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
    "name": "creator",
    "inputs": [],
    "outputs": [{"type": "address"}],
    "stateMutability": "view"
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
    "name": "CURRENCY",
    "inputs": [],
    "outputs": [{"type": "uint8"}],
    "stateMutability": "view"
  },
  // ✅ FUNCIONES V6 ACTIVADAS
  {
    "type": "function",
    "name": "lotteryName",
    "inputs": [],
    "outputs": [{"type": "string"}],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getLotteryInfo",
    "inputs": [],
    "outputs": [
      {"type": "string", "name": "name"},
      {"type": "address", "name": "creatorAddr"},
      {"type": "uint8", "name": "state"},
      {"type": "uint8", "name": "currency"},
      {"type": "address", "name": "token"},
      {"type": "uint256", "name": "ticketPrice"},
      {"type": "uint256", "name": "participantCount"},
      {"type": "uint256", "name": "prizePool"},
      {"type": "address", "name": "winnerAddr"}
    ],
    "stateMutability": "view"
  }
] as const;

// 🎯 ABI FACTORY V7 - VRF RELAY PATTERN
export const LOTTERY_FACTORY_ABI = [
  {
    "type": "function",
    "name": "createLotteryOpen",
    "inputs": [
      {"type": "uint8", "name": "currency"},
      {"type": "address", "name": "token"},
      {"type": "uint256", "name": "ticketPrice"},
      {"type": "string", "name": "lotteryName"}
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
    "name": "requestVRFForLottery",
    "inputs": [{"type": "address", "name": "lottery"}],
    "outputs": [{"type": "uint256"}],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "hasVRFPending",
    "inputs": [{"type": "address", "name": "lottery"}],
    "outputs": [{"type": "bool"}],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "isLotteryFromFactory",
    "inputs": [{"type": "address", "name": "lottery"}],
    "outputs": [{"type": "bool"}],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getLotteryCount",
    "inputs": [],
    "outputs": [{"type": "uint256"}],
    "stateMutability": "view"
  },
  {
    "type": "event",
    "name": "LotteryCreated",
    "inputs": [
      {"type": "address", "indexed": true, "name": "lottery"},
      {"type": "address", "indexed": true, "name": "creator"},
      {"type": "uint256", "name": "ticketPrice"},
      {"type": "string", "name": "name"}
    ]
  },
  {
    "type": "event",
    "name": "VRFRequested",
    "inputs": [
      {"type": "address", "indexed": true, "name": "lottery"},
      {"type": "uint256", "name": "requestId"}
    ]
  },
  {
    "type": "event",
    "name": "VRFFullfilled",
    "inputs": [
      {"type": "address", "indexed": true, "name": "lottery"},
      {"type": "uint256", "name": "requestId"},
      {"type": "uint256", "name": "randomNumber"}
    ]
  }
] as const;

// 🎯 ENUMS SIMPLES
export const LOTTERY_CURRENCY = {
  NATIVE: 0,  // ETH
  ERC20: 1    // Tokens
} as const;

export const LOTTERY_STATE = {
  Open: 0,      // 🟢 Abierta - se pueden comprar tickets
  Drawing: 1,   // 🔄 Sorteando - pidió VRF  
  Completed: 2, // ✅ Completada - ya hay ganador
  Cancelled: 3  // ❌ Cancelada
} as const;

// 🎯 MAPEO DE ESTADOS
export const LOTTERY_STATE_LABELS = {
  0: "🟢 Abierta",
  1: "🔄 Sorteando...", 
  2: "✅ Completada",
  3: "❌ Cancelada"
} as const;