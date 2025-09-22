import { useState } from 'react';
import { useCreateLottery } from '../hooks/useLottery';
import { useAccount } from 'wagmi';

interface CreateLotteryFormProps {
  onClose: () => void;
}

export default function CreateLotteryForm({ onClose }: CreateLotteryFormProps) {
  const { isConnected } = useAccount();
  const [ticketPrice, setTicketPrice] = useState('0.001');
  const [lotteryName, setLotteryName] = useState('');
  const [lotteryType, setLotteryType] = useState<'public' | 'private'>('public');
  
  const { createLottery, isPending, isSuccess, error, hash, reset } = useCreateLottery();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    console.log('🚀 Sending form:', {
      isConnected,
      ticketPrice,
      lotteryType
    });
    
    if (!isConnected) {
      alert('Please connect your wallet first');
      return;
    }

    if (parseFloat(ticketPrice) <= 0) {
      alert('Ticket price must be greater than 0');
      return;
    }

    // Only public lotteries are supported for now
    const isPrivate = false;
    console.log('✅ Creating lottery:', { isPrivate });
    createLottery(ticketPrice, lotteryName, isPrivate);
  };

  if (isSuccess) {
    setTimeout(() => {
      reset();
      onClose();
    }, 3000);
    
    return (
      <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div className="bg-gray-800 rounded-xl p-8 max-w-md w-full mx-4 text-center">
          <div className="text-green-400 text-4xl mb-4">🎉</div>
          <h2 className="text-2xl font-bold text-white mb-2">Lottery Created!</h2>
          <p className="text-gray-300 mb-4">Your lottery has been successfully created and is now live.</p>
          {hash && (
            <p className="text-xs text-gray-500 mb-4 font-mono">
              Hash: {hash.slice(0, 10)}...{hash.slice(-8)}
            </p>
          )}
          <div className="text-sm text-gray-400">Closing in 3 seconds...</div>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-gray-800 rounded-xl w-full max-w-md max-h-[90vh] flex flex-col">
        {/* Header fijo */}
        <div className="flex justify-between items-center p-6 pb-4 border-b border-gray-700">
          <h2 className="text-xl font-bold text-white">Create Lottery</h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white text-2xl"
          >
            ×
          </button>
        </div>
        
        {/* Contenido con scroll */}
        <div className="flex-1 overflow-y-auto p-6 pt-4">

        <form id="lottery-form" onSubmit={handleSubmit} className="space-y-5">
          {/* Lottery Type Selection */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Lottery Type
            </label>
            <div className="grid grid-cols-2 gap-2">
              <button
                type="button"
                onClick={() => setLotteryType('public')}
                className={`p-3 rounded-lg border-2 transition text-left ${
                  lotteryType === 'public'
                    ? 'border-indigo-500 bg-indigo-500/20 text-white'
                    : 'border-gray-600 bg-gray-700 text-gray-300 hover:border-gray-500'
                }`}
              >
                <div className="text-base mb-1">🌍 Public</div>
                <div className="text-xs opacity-80">Anyone can join</div>
              </button>
              
              <div
                className="p-3 rounded-lg border-2 border-gray-600 bg-gray-800 text-gray-500 cursor-not-allowed opacity-60 text-left relative"
              >
                <div className="text-base mb-1">🔐 Private</div>
                <div className="text-xs opacity-80">Coming Soon</div>
                <div className="absolute top-2 right-2 text-xs bg-yellow-600 text-yellow-100 px-2 py-1 rounded text-[10px] font-medium">
                  SOON
                </div>
              </div>
            </div>
          </div>



          {/* Ticket Price */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Ticket Price (ETH)
            </label>
            <input
              type="number"
              step="0.001"
              min="0.001"
              value={ticketPrice}
              onChange={(e) => setTicketPrice(e.target.value)}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-lg 
                       text-white placeholder-gray-400 focus:outline-none focus:ring-2 
                       focus:ring-indigo-500 focus:border-transparent"
              placeholder="0.01"
              required
            />
            <div className="text-xs text-gray-400 mt-1">
              Minimum: 0.001 ETH
            </div>
          </div>

          {/* Info sobre configuración */}
          {/* Lottery Name */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Lottery Name (Optional)
            </label>
            <input
              type="text"
              value={lotteryName}
              onChange={(e) => setLotteryName(e.target.value)}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-lg 
                       text-white placeholder-gray-400 focus:outline-none focus:ring-2 
                       focus:ring-indigo-500 focus:border-transparent"
              placeholder="My Awesome Lottery"
            />
            <div className="text-xs text-gray-400 mt-1">
              This name will be shown in the transaction
            </div>
          </div>

          <div className="p-4 bg-blue-900/30 border border-blue-500/30 rounded-lg">
            <h3 className="font-medium text-blue-300 mb-2">Lottery Configuration</h3>
            <div className="text-sm text-blue-200 space-y-1">
              <div>• Participants: No limit (open lottery)</div>
              <div>• Duration: Unlimited until manually closed</div>
              <div>• Currency: Native ETH (Sepolia)</div>
              <div>• Creator: alva-p</div>
            </div>
          </div>

          {/* Summary */}
          <div className="p-4 bg-gray-700/50 rounded-lg">
            <h3 className="font-medium text-white mb-2">Summary</h3>
            <div className="text-sm space-y-1 text-gray-300">
              <div>Name: {lotteryName || 'Unnamed Lottery'}</div>
              <div>Ticket Price: {ticketPrice} ETH</div>
              <div>Type: Open Lottery (unlimited participants)</div>
              <div>Network: Sepolia Testnet</div>
            </div>
          </div>


        </form>
        </div>
        
        {/* Footer fijo con botón */}
        <div className="p-6 pt-4 border-t border-gray-700">
          {!isConnected && (
            <div className="mb-4 p-3 bg-red-900/30 border border-red-500/30 rounded-lg text-red-400 text-sm text-center">
              Please connect your wallet to create a lottery
            </div>
          )}
          
          {error && (
            <div className="mb-4 p-3 bg-red-900/30 border border-red-500/30 rounded-lg text-red-400 text-sm">
              <div className="font-medium mb-1">Transaction Failed</div>
              <div className="text-xs opacity-80">{error.message}</div>
            </div>
          )}
          
          {hash && isPending && (
            <div className="mb-4 p-3 bg-blue-900/30 border border-blue-500/30 rounded-lg text-blue-400 text-sm">
              <div className="font-medium mb-1">Transaction Submitted</div>
              <div className="text-xs opacity-80 font-mono">
                Hash: {hash.slice(0, 10)}...{hash.slice(-8)}
              </div>
              <div className="text-xs mt-1">Waiting for confirmation...</div>
            </div>
          )}
          
          <button
            type="submit"
            form="lottery-form"
            disabled={!isConnected || isPending}
            className="w-full px-4 py-3 bg-indigo-600 hover:bg-indigo-500 disabled:bg-gray-600 
                     disabled:cursor-not-allowed text-white font-medium rounded-lg transition"
          >
            {isPending ? 'Creating Lottery...' : 'Create Lottery'}
          </button>
        </div>
      </div>
    </div>
  );
}