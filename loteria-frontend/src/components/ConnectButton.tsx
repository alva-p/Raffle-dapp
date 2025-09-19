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
        <span className="font-mono text-sm text-green-400">
          {address?.slice(0, 6)}...{address?.slice(-4)}
        </span>
        <button
          onClick={() => disconnect()}
          className="px-3 py-2 rounded bg-red-600 hover:bg-red-500 text-white"
        >
          Disconnect
        </button>
      </div>
    );
  }

  return (
    <div
      className="relative group"
      onMouseLeave={() => setIsOpen(false)} // cerrar al salir con el mouse
    >
      {/* Botón principal */}
      <button
        onClick={() => setIsOpen((prev) => !prev)} // toggle para mobile
        className="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded font-medium"
      >
        Connect Wallet
      </button>

      {/* Dropdown */}
      <div
        className={`
          absolute right-0 mt-2 w-56 bg-gray-800 border border-gray-700 rounded-lg shadow-lg z-10
          hidden group-hover:block
          ${isOpen ? "block" : ""}
        `}
      >
        {connectors.map((c) => (
          <button
            key={c.uid}
            onClick={() => handleConnect(c)}
            className="block w-full text-left px-4 py-2 text-gray-200 hover:bg-gray-700"
          >
            {c.name}
          </button>
        ))}
      </div>
    </div>
  );
}
