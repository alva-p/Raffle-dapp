import ConnectButton from "./components/ConnectButton";

export default function App() {
  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-b from-gray-950 to-gray-900 text-gray-100">
      {/* Header */}
      <header className="flex items-center justify-between px-8 py-4 border-b border-gray-800 sticky top-0 bg-gray-950/80 backdrop-blur-md z-50">
        <h1 className="text-2xl font-bold text-indigo-400 flex items-center gap-2">
          🎲 Loteria
        </h1>
        <ConnectButton />
      </header>

      {/* Hero Section */}
      <section className="flex flex-col items-center justify-center flex-1 text-center px-6 py-16">
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
            <button className="w-full px-4 py-2 rounded bg-indigo-600 hover:bg-indigo-500 transition text-white font-medium">
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
            <button className="w-full px-4 py-2 rounded bg-green-600 hover:bg-green-500 transition text-white font-medium">
              Explore Lotteries
            </button>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-4 text-center text-gray-500 border-t border-gray-800 text-sm">
        © {new Date().getFullYear()} Loteria · Built with ❤️ on Web3
      </footer>
    </div>
  );
}
