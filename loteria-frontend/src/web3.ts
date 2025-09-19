// src/web3.ts
import { createConfig, http } from 'wagmi';
import { sepolia } from 'wagmi/chains';
import { injected, metaMask } from 'wagmi/connectors';

/**
 * Config Wagmi para Sepolia.
 * Si definís VITE_RPC_URL, lo usa; si no, cae al RPC público de Sepolia.
 */
export const wagmiConfig = createConfig({
  chains: [sepolia],
  transports: {
    [sepolia.id]: http(import.meta.env.VITE_RPC_URL || 'https://rpc.sepolia.org'),
  },
 connectors: [
  metaMask(),
],
});
