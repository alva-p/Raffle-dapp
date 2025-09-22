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
  const [participantsFile, setParticipantsFile] = useState<File | null>(null);
  const [participantsList, setParticipantsList] = useState<string[]>([]);
  
  const { createLottery, isPending, isSuccess } = useCreateLottery();

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setParticipantsFile(file);
    
    const reader = new FileReader();
    reader.onload = (event) => {
      const text = event.target?.result as string;
      console.log('📄 Archivo leído:', text);
      
      // Soporte para ambos formatos: líneas separadas O comas
      let addresses: string[] = [];
      
      // Si contiene comas, procesar como CSV
      if (text.includes(',')) {
        addresses = text
          .split(/[,\n]/) // Separar por comas O saltos de línea
          .map(item => item.trim())
          .filter(item => {
            const isValid = item.length > 0 && item.startsWith('0x') && item.length >= 40;
            console.log(`🔍 Dirección: "${item}" (length: ${item.length}) -> ${isValid ? 'VÁLIDA' : 'INVÁLIDA'}`);
            return isValid;
          });
      } else {
        // Formato tradicional: una dirección por línea
        addresses = text
          .split('\n')
          .map(line => line.trim())
          .filter(line => {
            const isValid = line.length > 0 && line.startsWith('0x') && line.length >= 40;
            console.log(`🔍 Línea: "${line}" (length: ${line.length}) -> ${isValid ? 'VÁLIDA' : 'INVÁLIDA'}`);
            return isValid;
          });
      }
      
      console.log('✅ Direcciones procesadas:', addresses);
      setParticipantsList(addresses);
    };
    reader.readAsText(file);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    console.log('🚀 Enviando formulario:', {
      isConnected,
      ticketPrice,
      lotteryType,
      participantsList: participantsList.length,
      participantsFile: participantsFile?.name
    });
    
    if (!isConnected) {
      alert('Please connect your wallet first');
      return;
    }

    if (parseFloat(ticketPrice) <= 0) {
      alert('Ticket price must be greater than 0');
      return;
    }

    if (lotteryType === 'private' && participantsList.length === 0) {
      console.log('❌ Error: No hay participantes para lotería privada');
      alert(`Please upload a file with participant addresses for private lottery. Current participants: ${participantsList.length}`);
      return;
    }

    const isPrivate = lotteryType === 'private';
    console.log('✅ Creando lotería:', { isPrivate, participants: participantsList.length });
    createLottery(ticketPrice, lotteryName, isPrivate);
  };

  if (isSuccess) {
    setTimeout(() => {
      onClose();
    }, 2000);
    
    return (
      <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div className="bg-gray-800 rounded-xl p-8 max-w-md w-full mx-4 text-center">
          <div className="text-green-400 text-4xl mb-4">🎉</div>
          <h2 className="text-2xl font-bold text-white mb-2">Lottery Created!</h2>
          <p className="text-gray-300 mb-4">Your lottery has been successfully created and is now live.</p>
          <div className="text-sm text-gray-400">Closing in 2 seconds...</div>
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
              
              <button
                type="button"
                onClick={() => setLotteryType('private')}
                className={`p-3 rounded-lg border-2 transition text-left ${
                  lotteryType === 'private'
                    ? 'border-purple-500 bg-purple-500/20 text-white'
                    : 'border-gray-600 bg-gray-700 text-gray-300 hover:border-gray-500'
                }`}
              >
                <div className="text-base mb-1">🔐 Private</div>
                <div className="text-xs opacity-80">Import participants</div>
              </button>
            </div>
          </div>

          {/* File Upload for Private Lotteries */}
          {lotteryType === 'private' && (
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Upload Participants (.txt file)
              </label>
              <input
                type="file"
                accept=".txt"
                onChange={handleFileUpload}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-lg 
                         text-white file:mr-4 file:py-2 file:px-4 file:rounded-lg 
                         file:border-0 file:text-sm file:font-semibold 
                         file:bg-indigo-600 file:text-white hover:file:bg-indigo-500"
              />
              <div className="text-xs text-gray-400 mt-1">
                Upload a .txt file with Ethereum addresses:
                <br />• One per line: 0x123...<br />• Or comma-separated: 0x123..., 0x456...
              </div>
              
              {participantsList.length > 0 && (
                <div className="mt-2 p-2 bg-green-900/30 border border-green-500/30 rounded text-xs">
                  <div className="text-green-400 font-medium">
                    ✅ {participantsList.length} participants loaded
                  </div>
                  <div className="text-gray-400 mt-1">
                    {participantsList.slice(0, 2).join(', ')}
                    {participantsList.length > 2 && ` +${participantsList.length - 2} more...`}
                  </div>
                </div>
              )}
              
              {/* Debug info temporal */}
              <div className="mt-2 p-2 bg-blue-900/30 border border-blue-500/30 rounded text-xs">
                <div className="text-blue-400 font-medium">
                  🔍 Debug Info:
                </div>
                <div className="text-gray-400 mt-1">
                  • File: {participantsFile?.name || 'None'}
                  • Participants: {participantsList.length}
                  • Lottery Type: {lotteryType}
                </div>
              </div>
            </div>
          )}

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