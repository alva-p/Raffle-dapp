import { useAccount, useBalance } from 'wagmi';
import { formatEther } from 'viem';

export default function UserInfo() {
  const { address, isConnected } = useAccount();
  const { data: balance } = useBalance({ address });
  
  if (!isConnected) {
    return (
      <div className="bg-yellow-900/30 border border-yellow-500/30 rounded-lg p-3 text-yellow-400">
        ⚠️ Wallet not connected
      </div>
    );
  }

  return (
    <div className="bg-blue-900/30 border border-blue-500/30 rounded-lg p-3 text-blue-400">
      <div className="text-xs font-mono">
        <div><strong>Connected Account:</strong></div>
        <div className="break-all">{address}</div>
        {balance && (
          <div className="mt-1">
            <strong>Balance:</strong> {parseFloat(formatEther(balance.value)).toFixed(4)} ETH
          </div>
        )}
      </div>
    </div>
  );
}