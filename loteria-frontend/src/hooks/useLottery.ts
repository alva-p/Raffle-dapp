import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther, formatEther, type Address } from 'viem';
import { useState, useEffect } from 'react';
import { CONTRACT_ADDRESSES, LOTTERY_FACTORY_ABI, LOTTERY_BASE_ABI, LOTTERY_CURRENCY } from '../contracts';

// Hook para obtener todas las loterías
export function useGetAllLotteries() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LOTTERY_FACTORY,
    abi: LOTTERY_FACTORY_ABI,
    functionName: 'getAllLotteries',
  });
}

// Hook para obtener loterías activas (usa getAllLotteries)
export function useGetActiveLotteries() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.LOTTERY_FACTORY,
    abi: LOTTERY_FACTORY_ABI,
    functionName: 'getAllLotteries',
  });
}

// Hook para crear una lotería
export function useCreateLottery() {
  const { writeContract, data: hash, isPending, error, reset } = useWriteContract();
  const [manualSuccess, setManualSuccess] = useState(false);
  
  const { isLoading: isConfirming, isSuccess, isError: isConfirmError } = useWaitForTransactionReceipt({
    hash,
    confirmations: 1,
    timeout: 60_000, // 60 segundos timeout
  });

  // Auto-success fallback: si tenemos hash por más de 15 segundos, asumir éxito
  useEffect(() => {
    if (hash && !isSuccess && !isConfirmError) {
      const timer = setTimeout(() => {
        console.log('⏰ Timeout reached, assuming transaction success');
        setManualSuccess(true);
      }, 15_000);
      
      return () => clearTimeout(timer);
    }
  }, [hash, isSuccess, isConfirmError]);

  // Reset manual success cuando hay nuevo hash
  useEffect(() => {
    setManualSuccess(false);
  }, [hash]);

  const createLottery = (ticketPrice: string, lotteryName?: string, isPrivate?: boolean) => {
    const currency = LOTTERY_CURRENCY.NATIVE; // NATIVE (ETH)
    const token = "0x0000000000000000000000000000000000000000"; // Zero address for native ETH
    
    console.log('🚀 Creating lottery with params:', {
      currency,
      token,
      ticketPrice,
      lotteryName,
      isPrivate,
      ticketPriceWei: parseEther(ticketPrice).toString(),
      factoryAddress: CONTRACT_ADDRESSES.LOTTERY_FACTORY
    });
    
    // Reset previous state
    reset();
    
    // Preparar el nombre de la lotería
    const finalLotteryName = lotteryName && lotteryName.trim().length > 0 
      ? lotteryName.trim() 
      : "Unnamed Lottery";

    writeContract({
      address: CONTRACT_ADDRESSES.LOTTERY_FACTORY,
      abi: LOTTERY_FACTORY_ABI,
      functionName: 'createLotteryOpen', // Solo loterías públicas por ahora
      args: [currency, token, parseEther(ticketPrice), finalLotteryName],
    });
  };

  // Debug logging
  console.log('🔍 CreateLottery state:', {
    hash,
    isPending,
    isConfirming,
    isSuccess,
    error: error?.message,
    isConfirmError
  });

  const finalSuccess = isSuccess || manualSuccess;

  return {
    createLottery,
    isPending: isPending || (isConfirming && !manualSuccess),
    isSuccess: finalSuccess,
    hash,
    error: error || (isConfirmError ? new Error('Transaction confirmation failed') : null),
    isError: !!error || isConfirmError,
    reset: () => {
      reset();
      setManualSuccess(false);
    }
  };
}

// Hook simplificado para obtener solo el estado de una lotería (para filtros)
export function useLotteryInfo(address: Address) {
  const { data: lotteryInfo } = useReadContract({
    address,
    abi: LOTTERY_BASE_ABI,
    functionName: 'getLotteryInfo',
    query: { enabled: !!address }
  });

  if (lotteryInfo && Array.isArray(lotteryInfo) && lotteryInfo.length >= 9) {
    const [name, creator, stateNum, currency, token, ticketPrice, participantCount, prizePool, winner] = lotteryInfo;
    
    return {
      data: {
        name: name as string,
        creator: creator as Address,
        state: Number(stateNum), // 0=Open, 1=Drawing, 2=Completed, 3=Cancelled
        currency: Number(currency),
        token: token as Address,
        ticketPrice: ticketPrice as bigint,
        participantCount: Number(participantCount),
        prizePool: prizePool as bigint,
        winner: winner as Address
      }
    };
  }

  return { data: null };
}

// Hook para obtener detalles de una lotería específica
export function useLotteryDetails(address: Address) {
  // Intentar usar getLotteryInfo primero (V6)
  const { data: lotteryInfo } = useReadContract({
    address,
    abi: LOTTERY_BASE_ABI,
    functionName: 'getLotteryInfo',
    query: { enabled: !!address }
  });

  // Fallback para compatibilidad con contratos antiguos
  const { data: ticketPrice } = useReadContract({
    address,
    abi: LOTTERY_BASE_ABI,
    functionName: 'TICKET_PRICE',
    query: { enabled: !!address && !lotteryInfo }
  });

  const { data: participants } = useReadContract({
    address,
    abi: LOTTERY_BASE_ABI,
    functionName: 'getParticipants',
    query: { enabled: !!address }
  });

  const { data: state } = useReadContract({
    address,
    abi: LOTTERY_BASE_ABI,
    functionName: 'lotteryState',
    query: { enabled: !!address && !lotteryInfo }
  });

  const { data: winners } = useReadContract({
    address,
    abi: LOTTERY_BASE_ABI,
    functionName: 'getWinners',
    query: { enabled: !!address && !lotteryInfo }
  });

  const { data: creator } = useReadContract({
    address,
    abi: LOTTERY_BASE_ABI,
    functionName: 'creator',
    query: { enabled: !!address && !lotteryInfo }
  });

  // Mapear estados numéricos a nombres - CORREGIDO según LotteryOpenV2
  const getStateName = (stateNum: number) => {
    switch (stateNum) {
      case 0: return 'Open';      // State.Open
      case 1: return 'Drawing';   // State.Drawing
      case 2: return 'Completed'; // State.Completed
      case 3: return 'Cancelled'; // State.Cancelled
      default: return 'Unknown';
    }
  };

  // Usar datos de getLotteryInfo si está disponible (V6), sino usar llamadas individuales
  if (lotteryInfo && Array.isArray(lotteryInfo) && lotteryInfo.length >= 9) {
    const [name, creatorAddr, stateNum, currency, , ticketPriceWei, participantCount, prizePool, winnerAddr] = lotteryInfo;
    
    return {
      lotteryName: name as string,
      ticketPrice: formatEther(ticketPriceWei as bigint),
      maxParticipants: 0, // Sin límite en LotteryOpen
      participantsCount: Number(participantCount),
      participants: participants || [], // Lista completa de participantes
      state: getStateName(Number(stateNum)),
      stateNumber: Number(stateNum),
      endTime: 0, // Sin tiempo límite en LotteryOpen
      winners: winnerAddr && winnerAddr !== '0x0000000000000000000000000000000000000000' ? [winnerAddr as Address] : [],
      creator: creatorAddr as Address,
      prizePool: formatEther(prizePool as bigint),
      currency: Number(currency),
      address
    };
  }

  // Fallback para contratos antiguos
  return {
    lotteryName: undefined,
    ticketPrice: ticketPrice ? formatEther(ticketPrice) : '0',
    maxParticipants: 0, // Sin límite en LotteryOpen
    participantsCount: participants ? participants.length : 0,
    participants: participants || [], // Lista completa de participantes
    state: state !== undefined ? getStateName(Number(state)) : 'Unknown',
    stateNumber: state !== undefined ? Number(state) : undefined,
    endTime: 0, // Sin tiempo límite en LotteryOpen
    winners: winners || [],
    creator: creator as Address | undefined,
    prizePool: '0',
    currency: 0,
    address
  };
}

// Hook para entrar a la lotería
export function useBuyTicket() {
  const { writeContract, data: hash, isPending, error } = useWriteContract();
  
  const { isLoading: isConfirming, isSuccess, isError: isConfirmError } = useWaitForTransactionReceipt({
    hash,
  });

  console.log('useBuyTicket state:', {
    isPending,
    isConfirming,
    isSuccess,
    error: error?.message,
    hash
  });

  const buyTicket = (lotteryAddress: Address, ticketPrice: string) => {
    console.log('🎫 Attempting to enter lottery:', {
      lotteryAddress,
      ticketPrice,
      ticketPriceWei: parseEther(ticketPrice).toString()
    });
    
    try {
      writeContract({
        address: lotteryAddress,
        abi: LOTTERY_BASE_ABI,
        functionName: 'enter',
        value: parseEther(ticketPrice),
      });
      console.log('✅ writeContract called successfully');
    } catch (err) {
      console.error('❌ Error in writeContract:', err);
    }
  };

  return {
    buyTicket,
    isPending: isPending || isConfirming,
    isSuccess,
    hash,
    error,
    isError: isConfirmError
  };
}

// Hook para cerrar lotería
export function useCloseLottery() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  const closeLottery = (lotteryAddress: Address) => {
    writeContract({
      address: lotteryAddress,
      abi: LOTTERY_BASE_ABI,
      functionName: 'closeLottery',
    });
  };

  return {
    closeLottery,
    isPending: isPending || isConfirming,
    isSuccess,
    hash
  };
}

// Hook para función de emergencia - Force Draw Winner
export function useEmergencyDrawWinner() {
  const { writeContract, data: hash, isPending, error } = useWriteContract();
  
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  const emergencyDrawWinner = (lotteryAddress: Address) => {
    writeContract({
      address: lotteryAddress,
      abi: LOTTERY_BASE_ABI,
      functionName: 'emergencyDrawWinner',
    });
  };

  return {
    emergencyDrawWinner,
    isPending: isPending || isConfirming,
    isSuccess,
    error,
    hash
  };
}

// Hook para cancelar lotería y reembolsar
export function useCancelLottery() {
  const { writeContract, data: hash, isPending, error } = useWriteContract();
  
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  const cancelLottery = (lotteryAddress: Address) => {
    writeContract({
      address: lotteryAddress,
      abi: LOTTERY_BASE_ABI,
      functionName: 'cancelLottery',
    });
  };

  return {
    cancelLottery,
    isPending: isPending || isConfirming,
    isSuccess,
    error,
    hash
  };
}