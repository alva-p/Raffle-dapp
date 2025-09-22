import { useState } from "react";
import { useConnect, useDisconnect, useAccount } from "wagmi";

export default function ConnectButton() {
  const { address, isConnected } = useAccount();
  const { connectors, connectAsync } = useConnect();
  const { disconnect } = useDisconnect();

  const [isOpen, setIsOpen] = useState(false);

  const handleConnect = async (connector: any) => {
    try {
      await connectAsync({ connector });
      setIsOpen(false); // cerrar menú en mobile
    } catch (err: any) {
      if (err?.message?.includes("User rejected")) {
        console.log("❌ User rejected connection");
      } else {
        console.error("Unexpected error:", err);
      }
    }
  };

  if (isConnected) {
    return (
      <div className="flex items-center gap-3">
        {/* 🌟 Wallet address con efecto titilante personalizado */}
        <div className="relative flex items-center gap-2 px-3 py-2 bg-green-900/30 border border-green-500/30 rounded-lg hover:bg-green-900/50 transition-all duration-300 group wallet-container">
          {/* Indicador de conexión con pulso */}
          <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
          
          {/* Dirección con efecto de titilante suave y text-shadow */}
          <span className="font-mono text-sm text-green-400 wallet-blink font-semibold">
            {address?.slice(0, 6)}...{address?.slice(-4)}
          </span>
          
          {/* Efecto de brillo sutil en hover */}
          <div className="absolute inset-0 bg-green-500/10 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none"></div>
        </div>
        
        <button
          onClick={() => disconnect()}
          className="px-3 py-2 rounded-lg bg-red-600 hover:bg-red-500 text-white transition-all font-medium hover:scale-105 active:scale-95"
        >
          Disconnect
        </button>
      </div>
    );
  }

  return (
    <div className="relative">
      {/* Botón principal */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg font-medium transition-all"
      >
        Connect Wallet
      </button>

      {/* Dropdown */}
      {isOpen && (
        <>
          {/* Overlay para cerrar al hacer click fuera */}
          <div
            className="fixed inset-0 z-10"
            onClick={() => setIsOpen(false)}
          />
          
          {/* Menú de opciones */}
          <div className="absolute right-0 mt-2 w-56 bg-gray-800 border border-gray-700 rounded-lg shadow-xl z-20 py-2">
            <div className="px-4 py-2 text-xs text-gray-400 border-b border-gray-700">
              Choose a wallet to connect
            </div>
            {connectors.map((connector) => (
              <button
                key={connector.uid}
                onClick={() => handleConnect(connector)}
                className="block w-full text-left px-4 py-3 text-gray-200 hover:bg-gray-700 transition-colors first:mt-2"
              >
                <div className="flex items-center gap-3">
                  <div className="w-6 h-6 bg-gradient-to-r from-indigo-500 to-purple-600 rounded-full flex items-center justify-center text-xs font-bold">
                    {connector.name.charAt(0)}
                  </div>
                  <span>{connector.name}</span>
                </div>
              </button>
            ))}
          </div>
        </>
      )}
    </div>
  );
}
