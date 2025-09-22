// 🎯 CONTRATOS MVP SIMPLE
export const CONTRACT_ADDRESSES = {
  LOTTERY_FACTORY: "0x3887d63AebF99F7E27Bd52901d35F106d8a3BCA9", // Factory V5 - VRF DIRECTO
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
  }
] as const;

// 🎯 ABI FACTORY V5
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
    "name": "getAllLotteries",
    "inputs": [],
    "outputs": [{"type": "address[]"}],
    "stateMutability": "view"
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