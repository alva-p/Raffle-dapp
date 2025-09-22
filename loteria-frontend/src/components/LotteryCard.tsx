import { type Address } from 'viem';
import { useLotteryDetails, useBuyTicket, useCloseLottery, useEmergencyDrawWinner, useCancelLottery } from '../hooks/useLottery';
import { useAccount } from 'wagmi';
import { useState, useEffect } from 'react';

interface LotteryCardProps {
  address: Address;
}

export default function LotteryCard({ address }: LotteryCardProps) {
  const { address: userAddress, isConnected } = useAccount();
  const [isExpanded, setIsExpanded] = useState(false);
  
  const {
    ticketPrice,
    maxParticipants,
    participantsCount,
    state,
    stateNumber,
    endTime,
    winners,
    creator,
  } = useLotteryDetails(address);

  const { buyTicket, isPending: isBuying, error: buyError, isSuccess: buySuccess } = useBuyTicket();
  const { closeLottery, isPending: isClosing } = useCloseLottery();
  const { emergencyDrawWinner, isPending: isEmergencyDrawing } = useEmergencyDrawWinner();
  const { cancelLottery, isPending: isCancelling } = useCancelLottery();

  const isOpen = stateNumber === 0; // Open state (0 = Open) - allows entries
  const isDrawing = stateNumber === 1; // Drawing state (1 = Drawing)  
  const isClosed = stateNumber === 2; // Completed state (2 = Completed)
  // LotteryOpen no tiene límite de participantes (maxParticipants = 0 significa ilimitado)
  const isFull = maxParticipants > 0 && participantsCount >= maxParticipants;
  const isExpired = endTime > 0 && Date.now() / 1000 > endTime;
  
  const canBuyTicket = isOpen && !isFull && !isExpired && isConnected;

  // Auto-refresh for lotteries waiting for VRF result
  useEffect(() => {
    let interval: NodeJS.Timeout;
    
    // If lottery is closed but no winners yet, auto-refresh every 30 seconds
    if (isClosed && (!winners || winners.length === 0)) {
      console.log('🔄 Auto-refreshing lottery waiting for VRF result:', address);
      interval = setInterval(() => {
        window.location.reload(); // Simple refresh - could be optimized to just refetch data
      }, 30000); // 30 seconds
    }
    
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isClosed, winners, address]);

  console.log('LotteryCard render:', {
    lotteryAddress: address,
    userAddress,
    state,
    stateNumber,
    canBuyTicket,
    isConnected,
    isOpen,
    isDrawing,
    isClosed,
    isFull,
    isExpired,
    creator,
    participantsCount,
    ticketPrice,
    winnersCount: winners?.length || 0
  });

  const handleBuyTicket = () => {
    if (!isConnected) {
      alert('Please connect your wallet first');
      return;
    }
    buyTicket(address, ticketPrice);
  };

  const handleCloseLottery = () => {
    if (!isConnected) {
      alert('Please connect your wallet first');
      return;
    }
    closeLottery(address);
  };

  const getStateColor = () => {
    if (isOpen && !isFull && !isExpired) return 'text-green-400 bg-green-400/10';
    if (isDrawing) return 'text-yellow-400 bg-yellow-400/10';
    if (isClosed) return 'text-gray-400 bg-gray-400/10';
    if (isFull || isExpired) return 'text-red-400 bg-red-400/10';
    return 'text-gray-400 bg-gray-400/10';
  };

  const getStateText = () => {
    if (isOpen && !isFull && !isExpired) return 'Open';
    if (isOpen && isFull) return 'Full';
    if (isOpen && isExpired) return 'Expired';
    if (isDrawing) return 'Drawing';
    if (isClosed) return 'Closed';
    return state;
  };

  const formatEndTime = (timestamp: number) => {
    if (timestamp === 0) return 'No end time';
    const date = new Date(timestamp * 1000);
    return date.toLocaleString();
  };

  const canClose = isOpen && isConnected && (creator?.toLowerCase() === userAddress?.toLowerCase());
  const isCreator = creator?.toLowerCase() === userAddress?.toLowerCase();

  return (
    <div className="bg-gray-800 rounded-xl p-6 shadow-lg hover:shadow-indigo-500/20 transition-all border border-gray-700">
      {/* Header */}
      <div className="flex justify-between items-start mb-4">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-2">
            <h3 className="font-mono text-sm text-gray-300">
              {address.slice(0, 8)}...{address.slice(-6)}
            </h3>
            <button
              onClick={() => setIsExpanded(!isExpanded)}
              className="text-gray-400 hover:text-white text-xs"
            >
              {isExpanded ? '↑' : '↓'}
            </button>
          </div>
          
          {/* Creator Info */}
          {creator && (
            <div className="text-xs text-gray-400 mb-1">
              <span className="text-gray-500">Creator:</span> 
              <span className="font-mono ml-1">
                {creator.slice(0, 6)}...{creator.slice(-4)}
              </span>
              {creator.toLowerCase() === userAddress?.toLowerCase() && (
                <span className="ml-2 px-1 py-0.5 bg-indigo-600 text-indigo-200 rounded text-xs">YOU</span>
              )}
            </div>
          )}
          
          <div className={`px-2 py-1 rounded-full text-xs font-medium ${getStateColor()}`}>
            {getStateText()}
          </div>
        </div>
        <div className="text-right">
          <div className="text-2xl font-bold text-white">{ticketPrice} ETH</div>
          <div className="text-sm text-gray-400">per ticket</div>
        </div>
      </div>

      {/* Participants Progress */}
      <div className="mb-4">
        <div className="flex justify-between text-sm text-gray-400 mb-1">
          <span>Participants</span>
          <span>{participantsCount}{maxParticipants > 0 ? `/${maxParticipants}` : ' (unlimited)'}</span>
        </div>
        <div className="w-full bg-gray-700 rounded-full h-2">
          <div
            className="bg-gradient-to-r from-indigo-500 to-purple-600 h-2 rounded-full transition-all"
            style={{ width: maxParticipants > 0 ? `${(participantsCount / maxParticipants) * 100}%` : '20%' }}
          />
        </div>
      </div>

      {/* Expanded Details */}
      {isExpanded && (
        <div className="mb-4 p-3 bg-gray-900/50 rounded-lg text-sm space-y-2">
          <div className="flex justify-between">
            <span className="text-gray-400">Creator:</span>
            <span className="font-mono text-white">
              {creator ? `${creator.slice(0, 6)}...${creator.slice(-4)}` : 'Unknown'}
            </span>
          </div>
          {winners && winners.length > 0 && (
            <div className="flex justify-between">
              <span className="text-gray-400">Winner:</span>
              <span className="font-mono text-green-400">
                {winners[0].slice(0, 8)}...{winners[0].slice(-6)}
              </span>
            </div>
          )}
          <div className="flex justify-between">
            <span className="text-gray-400">Prize Pool:</span>
            <span className="text-white">{(parseFloat(ticketPrice) * participantsCount).toFixed(4)} ETH</span>
          </div>
        </div>
      )}

      {/* Debug Info */}
      {isExpanded && (
        <div className="mb-4 p-3 bg-gray-900/50 rounded-lg text-xs">
          <div className="text-gray-400 space-y-1">
            <div><strong>Lottery:</strong> {address?.slice(0, 8)}...{address?.slice(-4)}</div>
            <div><strong>State:</strong> {state} (#{stateNumber})</div>
            <div><strong>Ticket Price:</strong> {ticketPrice} ETH</div>
            <div><strong>Participants:</strong> {participantsCount}</div>
            <div><strong>Connected User:</strong> {userAddress?.slice(0, 8)}...{userAddress?.slice(-4)}</div>
            <div><strong>Is Connected:</strong> {isConnected ? '✅' : '❌'}</div>
            <div><strong>Is Open:</strong> {isOpen ? '✅' : '❌'}</div>
            <div><strong>Is Full:</strong> {isFull ? '❌' : '✅'}</div>
            <div><strong>Is Expired:</strong> {isExpired ? '❌' : '✅'}</div>
            <div><strong>Can Buy Ticket:</strong> {canBuyTicket ? '✅' : '❌'}</div>
            {buyError && <div className="text-red-400"><strong>Last Error:</strong> {buyError.message}</div>}
          </div>
        </div>
      )}

      {/* Actions */}
      <div className="space-y-2">
        {/* Current Account Info */}
        {isConnected && (
          <div className="p-2 bg-blue-900/20 border border-blue-500/20 rounded text-blue-300 text-xs mb-2">
            <strong>Active Account:</strong> {userAddress?.slice(0, 10)}...{userAddress?.slice(-6)}
          </div>
        )}

        {/* Error Messages */}
        {buyError && (
          <div className="p-2 bg-red-900/30 border border-red-500/30 rounded text-red-400 text-xs">
            <strong>❌ Transaction Failed:</strong><br />
            {buyError.message}
            <br /><br />
            <strong>Troubleshooting:</strong><br />
            • Check you have enough ETH for gas + ticket<br />
            • Make sure the correct account is selected in MetaMask<br />
            • Try refreshing and reconnecting wallet
          </div>
        )}
        
        {buySuccess && (
          <div className="p-2 bg-green-900/30 border border-green-500/30 rounded text-green-400 text-xs">
            ✅ Successfully entered lottery!
          </div>
        )}

        {/* Helpful hints */}
        {!canBuyTicket && isConnected && (
          <div className="p-2 bg-yellow-900/20 border border-yellow-500/20 rounded text-yellow-300 text-xs">
            {!isOpen && `⚠️ Lottery state: ${state} (${stateNumber}) - Not accepting entries`}
            {isOpen && isFull && "⚠️ This lottery is full"}
            {isOpen && isExpired && "⚠️ This lottery has expired"}
            {stateNumber === undefined && "⚠️ Loading lottery state..."}
          </div>
        )}

        {/* Debug Info for Creator Controls */}
        {isConnected && (
          <div className="p-2 bg-blue-900/20 border border-blue-500/20 rounded text-blue-300 text-xs space-y-1">
            <div className="font-semibold text-blue-200">🔍 Debug Info:</div>
            <div>Connected: {isConnected ? '✅' : '❌'}</div>
            <div>Your Address: {userAddress?.slice(0, 6)}...{userAddress?.slice(-4) || 'None'}</div>
            <div>Creator: {creator?.slice(0, 6)}...{creator?.slice(-4) || 'Loading...'}</div>
            <div>Are you creator?: {isCreator ? '✅ YES' : '❌ NO'}</div>
            <div>Lottery State: {state} ({stateNumber})</div>
            <div>Is Open?: {isOpen ? '✅' : '❌'}</div>
            <div>Participants: {participantsCount}</div>
            <div>Can show creator controls?: {canClose ? '✅ YES' : '❌ NO'}</div>
            {!canClose && isCreator && (
              <div className="text-yellow-300">⚠️ You're the creator but lottery is not open anymore</div>
            )}
            {!canClose && !isCreator && creator && (
              <div className="text-red-300">❌ You're not the creator of this lottery</div>
            )}
          </div>
        )}

        {canBuyTicket && (
          <button
            onClick={handleBuyTicket}
            disabled={isBuying}
            className="w-full px-4 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:bg-gray-600 
                     disabled:cursor-not-allowed text-white font-medium rounded-lg transition"
          >
            {isBuying ? 'Entering...' : 'Enter Lottery'}
          </button>
        )}
        
        {canClose && (
          <div className="space-y-3">
            {/* Creator Badge and Status */}
            <div className="bg-purple-900/30 border border-purple-500/30 rounded-lg p-3">
              <div className="text-purple-400 font-semibold text-sm mb-2 flex items-center gap-2">
                👑 Creator Controls
              </div>
              
              {participantsCount > 0 ? (
                <div className="text-xs text-green-400 mb-2 flex items-center gap-2">
                  ✅ {participantsCount} participant{participantsCount > 1 ? 's' : ''} ready for Chainlink VRF draw!
                  <div className="text-yellow-300">
                    Prize: {(parseFloat(ticketPrice) * participantsCount).toFixed(4)} ETH
                  </div>
                </div>
              ) : (
                <div className="text-xs text-gray-400 mb-2">
                  ⏳ Waiting for participants to join...
                </div>
              )}
            </div>
            
            {/* Start Raffle Button */}
            <button
              onClick={handleCloseLottery}
              disabled={isClosing || participantsCount === 0}
              className={`w-full px-4 py-3 font-semibold rounded-lg transition-all duration-200 flex items-center justify-center gap-2 ${
                participantsCount > 0 
                  ? 'bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700 text-white shadow-lg hover:shadow-orange-500/25' 
                  : 'bg-gray-600 text-gray-400 cursor-not-allowed'
              }`}
            >
              {isClosing ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                  Starting Chainlink VRF...
                </>
              ) : (
                <>
                  🎲 Start Raffle with VRF
                  {participantsCount > 0 && (
                    <span className="text-xs bg-white/20 px-2 py-1 rounded">
                      {participantsCount} entries
                    </span>
                  )}
                </>
              )}
            </button>
          </div>
        )}

        {/* Emergency Controls for Creator */}
        {isDrawing && canClose && (
          <div className="mt-3 p-3 bg-red-900/20 border border-red-500/30 rounded">
            <div className="text-red-400 text-xs mb-2 font-medium">🚨 Emergency Controls</div>
            <div className="text-xs text-red-300 mb-3">
              VRF taking too long? Use emergency functions.
            </div>
            <div className="space-y-2">
              <button
                onClick={() => emergencyDrawWinner(address)}
                disabled={isEmergencyDrawing}
                className="w-full px-3 py-2 bg-orange-600 hover:bg-orange-500 disabled:bg-orange-800 text-white text-xs rounded transition"
              >
                {isEmergencyDrawing ? '⏳ Drawing...' : '🎯 Force Draw Winner'}
              </button>
              <button
                onClick={() => cancelLottery(address)}
                disabled={isCancelling}
                className="w-full px-3 py-2 bg-red-600 hover:bg-red-500 disabled:bg-red-800 text-white text-xs rounded transition"
              >
                {isCancelling ? '⏳ Cancelling...' : '❌ Cancel & Refund All'}
              </button>
            </div>
          </div>
        )}

        {/* Cancel Option for Open Lottery - MEJORADO */}
        {isOpen && canClose && participantsCount > 0 && (
          <div className="mt-3">
            <div className="bg-red-900/20 border border-red-500/30 rounded-lg p-3">
              <div className="text-red-400 text-xs mb-2 font-medium">⚠️ Cancel Lottery</div>
              <div className="text-xs text-red-300 mb-3">
                This will refund {(parseFloat(ticketPrice)).toFixed(4)} ETH to each of the {participantsCount} participant{participantsCount > 1 ? 's' : ''}.
              </div>
              <button
                onClick={() => {
                  const confirmed = window.confirm(
                    `Are you sure you want to cancel this lottery?\n\nThis will refund ${(parseFloat(ticketPrice)).toFixed(4)} ETH to each of the ${participantsCount} participant${participantsCount > 1 ? 's' : ''}.\n\nTotal refund: ${(parseFloat(ticketPrice) * participantsCount).toFixed(4)} ETH`
                  );
                  if (confirmed) {
                    cancelLottery(address);
                  }
                }}
                disabled={isCancelling}
                className="w-full px-4 py-2 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 disabled:from-gray-600 disabled:to-gray-700 disabled:cursor-not-allowed text-white font-semibold rounded-lg transition-all duration-200 flex items-center justify-center gap-2"
              >
                {isCancelling ? (
                  <>
                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                    Processing Refunds...
                  </>
                ) : (
                  <>
                    🚫 Cancel & Refund All
                    <span className="text-xs bg-white/20 px-2 py-1 rounded">
                      {(parseFloat(ticketPrice) * participantsCount).toFixed(4)} ETH
                    </span>
                  </>
                )}
              </button>
            </div>
          </div>
        )}

        {/* Lottery Completed - Show Winners */}
        {isClosed && (
          <div className="space-y-3">
            {winners && winners.length > 0 ? (
              <div className="p-4 bg-green-900/30 border border-green-500/30 rounded-lg">
                <div className="text-green-400 font-medium text-center mb-3 flex items-center justify-center gap-2">
                  🎉 Lottery Completed!
                  <span className="text-xs bg-green-600 px-2 py-1 rounded">
                    {winners.length} Winner{winners.length > 1 ? 's' : ''}
                  </span>
                </div>
                <div className="space-y-2">
                  {winners.map((winner, index) => (
                    <div key={index} className="bg-green-900/50 p-3 rounded flex justify-between items-center">
                      <div>
                        <div className="font-mono text-sm text-green-300">
                          {winner.slice(0, 12)}...{winner.slice(-8)}
                        </div>
                        <div className="text-xs text-green-400">
                          Winner #{index + 1}
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-green-300 font-medium">
                          {((parseFloat(ticketPrice) * participantsCount) / winners.length).toFixed(4)} ETH
                        </div>
                        <div className="text-xs text-green-400">Prize</div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ) : (
              <div className="p-3 bg-yellow-900/30 border border-yellow-500/30 rounded-lg text-center">
                <div className="text-yellow-400 font-medium">⏳ Processing VRF...</div>
                <div className="text-xs text-yellow-300 mt-1">
                  Chainlink VRF is determining the winner. This may take a few minutes.
                </div>
                <button
                  onClick={() => window.location.reload()}
                  className="mt-2 px-3 py-1 bg-yellow-600 hover:bg-yellow-500 text-white text-xs rounded transition"
                >
                  Refresh to Check
                </button>
              </div>
            )}
          </div>
        )}

        {!isConnected && (
          <div className="text-center text-gray-400 text-sm py-2">
            Connect wallet to participate
          </div>
        )}
      </div>
    </div>
  );
}