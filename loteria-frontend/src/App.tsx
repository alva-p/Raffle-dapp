import { useState, useEffect } from "react";
import ConnectButton from "./components/ConnectButton";
import LotteryCard from "./components/LotteryCard";
import CreateLotteryForm from "./components/CreateLotteryForm";
import UserInfo from "./components/UserInfo";
import { useGetActiveLotteries } from "./hooks/useLottery";
import { useAccount } from "wagmi";
import { type Address } from "viem";

export default function App() {
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [currentView, setCurrentView] = useState<'home' | 'lotteries'>('home');
  const [lotteryType, setLotteryType] = useState<'public' | 'private'>('public');
  
  const { address: currentAccount } = useAccount();
  const { data: activeLotteries = [], isLoading: isLoadingLotteries, refetch } = useGetActiveLotteries();

  // Refetch data when account changes
  useEffect(() => {
    if (currentAccount) {
      console.log('🔄 Account changed, refreshing lottery data:', currentAccount);
      refetch();
    }
  }, [currentAccount, refetch]);

  console.log('🏠 App render state:', {
    currentView,
    showCreateForm,
    activeLotteries,
    isLoadingLotteries
  });

  const handleCreateLottery = () => {
    setShowCreateForm(true);
  };

  const handleExploreLotteries = () => {
    console.log('🔍 Exploring lotteries...');
    setCurrentView('lotteries');
    console.log('📊 Current view set to:', 'lotteries');
    refetch();
  };

  const handleBackHome = () => {
    setCurrentView('home');
  };

  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-b from-gray-950 to-gray-900 text-gray-100">
      {/* Header */}
      <header className="flex items-center justify-between px-8 py-4 border-b border-gray-800 sticky top-0 bg-gray-950/80 backdrop-blur-md z-50">
        <h1 
          className="text-2xl font-bold text-indigo-400 flex items-center gap-2 cursor-pointer hover:text-indigo-300 transition"
          onClick={handleBackHome}
        >
          🎲 Lottery
        </h1>
        <div className="flex items-center gap-4">
          {currentView === 'lotteries' && (
            <button
              onClick={handleBackHome}
              className="px-3 py-2 text-gray-300 hover:text-white transition"
            >
              ← Home
            </button>
          )}
          <ConnectButton />
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 flex flex-col min-h-0">
        {currentView === 'home' ? (
          /* Hero Section */
          <section className="flex flex-col items-center justify-center flex-1 text-center px-6 py-8">
            <h2 className="text-5xl font-extrabold mb-6">
              Welcome to <span className="text-indigo-400">Loteria</span>
            </h2>
            <p className="text-gray-400 max-w-2xl mb-12">
              Create and join decentralized lotteries powered by smart contracts and
              verifiable randomness. Simple, transparent, and fair.
            </p>

            {/* Main Options */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 w-full max-w-4xl">
              {/* Create Lottery Card */}
              <div className="bg-gray-800 rounded-xl p-6 shadow-lg hover:shadow-indigo-500/30 transition">
                <h3 className="text-xl font-semibold mb-2 text-white">
                  Create a Lottery
                </h3>
                <p className="text-gray-400 mb-4">
                  Set up your own lottery by choosing ticket price, number of
                  winners, and participant limit.
                </p>
                <button 
                  onClick={handleCreateLottery}
                  className="w-full px-4 py-2 rounded bg-indigo-600 hover:bg-indigo-500 transition text-white font-medium"
                >
                  Create Lottery
                </button>
              </div>

              {/* Join Lottery Card */}
              <div className="bg-gray-800 rounded-xl p-6 shadow-lg hover:shadow-green-500/30 transition">
                <h3 className="text-xl font-semibold mb-2 text-white">
                  Join a Lottery
                </h3>
                <p className="text-gray-400 mb-4">
                  Browse active lotteries and join by purchasing a ticket with your
                  wallet.
                </p>
                <button 
                  onClick={handleExploreLotteries}
                  className="w-full px-4 py-2 rounded bg-green-600 hover:bg-green-500 transition text-white font-medium"
                >
                  Explore Lotteries
                </button>
              </div>
            </div>
          </section>
        ) : (
          /* Lotteries List */
          <section className="flex-1 px-6 py-8 min-h-screen">
            <div className="max-w-6xl mx-auto text-white">


              {/* User Info */}
              <div className="mb-6">
                <UserInfo />
              </div>

              <div className="flex justify-between items-center mb-8">
                <div>
                  <h2 className="text-3xl font-bold text-white mb-2">Active Lotteries</h2>
                  <p className="text-gray-400">
                    {activeLotteries.length} active {activeLotteries.length === 1 ? 'lottery' : 'lotteries'}
                  </p>
                </div>
                <div className="flex gap-4">
                  <button
                    onClick={handleBackHome}
                    className="px-6 py-3 bg-gray-700 hover:bg-gray-600 text-white font-medium rounded-lg transition"
                  >
                    ← Back to Home
                  </button>
                  <button
                    onClick={handleCreateLottery}
                    className="px-6 py-3 bg-indigo-600 hover:bg-indigo-500 text-white font-medium rounded-lg transition"
                  >
                    + Create Lottery
                  </button>
                </div>
              </div>

              {isLoadingLotteries ? (
                <div className="text-center py-12 bg-yellow-900/30 border border-yellow-500/30 rounded">
                  <div className="inline-block w-8 h-8 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
                  <p className="text-yellow-400 mt-4">Loading lotteries...</p>
                </div>
              ) : activeLotteries.length === 0 ? (
                <div className="text-center py-12 bg-gray-800/50 border border-gray-600 rounded">
                  <div className="text-6xl mb-4">🎲</div>
                  <h3 className="text-xl font-semibold text-white mb-2">No Active Lotteries</h3>
                  <p className="text-gray-400 mb-6">Be the first to create a lottery!</p>
                  <button
                    onClick={handleCreateLottery}
                    className="px-6 py-3 bg-indigo-600 hover:bg-indigo-500 text-white font-medium rounded-lg transition"
                  >
                    Create First Lottery
                  </button>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {activeLotteries.map((address) => (
                    <LotteryCard key={address} address={address as Address} />
                  ))}
                </div>
              )}
            </div>
          </section>
        )}
      </main>

      {/* Footer */}
      <footer className="py-4 text-center text-gray-500 border-t border-gray-800 text-sm">
        © {new Date().getFullYear()} Loteria · Built with ❤️ on Web3
      </footer>

      {/* Create Lottery Modal */}
      {showCreateForm && (
        <CreateLotteryForm onClose={() => setShowCreateForm(false)} />
      )}
    </div>
  );
}
