// src/web3.ts
import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { http } from 'wagmi';
import { sepolia } from 'wagmi/chains';

// Configuración RainbowKit + Wagmi para Sepolia con Alchemy
export const wagmiConfig = getDefaultConfig({
  appName: 'Lotería Dapp',
  projectId: 'JFD5LtlpNb9DcEhBq_YUD', // Usamos tu API Key de Alchemy como projectId para WalletConnect
  chains: [sepolia],
  transports: {
    [sepolia.id]: http('https://eth-sepolia.g.alchemy.com/v2/JFD5LtlpNb9DcEhBq_YUD'),
  },
  ssr: false,
});
