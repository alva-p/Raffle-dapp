import { useAccount, useConnect, useDisconnect } from "wagmi";

export function useWalletStatus() {
  const { address, isConnected, status: accountStatus } = useAccount();
  const { connectors, connect, status: connectStatus, error } = useConnect();
  const { disconnect } = useDisconnect();

  return {
    address,
    isConnected,
    accountStatus,
    connectors,
    connect,
    disconnect,

    // Mapear a booleanos con el nuevo status
    isConnecting: connectStatus === "pending",
    isSuccess: connectStatus === "success",
    isIdle: connectStatus === "idle",
    isError: connectStatus === "error",
    error,
  };
}
