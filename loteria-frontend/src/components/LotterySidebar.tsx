// Sidebar for filtering lotteries by state

export type FilterState = 'all' | 'open' | 'completed' | 'cancelled' | 'drawing';

interface SidebarProps {
  activeFilter: FilterState;
  onFilterChange: (filter: FilterState) => void;
  lotteryCounts: Record<FilterState, number>;
}

export default function LotterySidebar({ activeFilter, onFilterChange, lotteryCounts }: SidebarProps) {
  const filterOptions = [
    {
      key: 'all' as FilterState,
      label: '🎯 All Lotteries',
      description: 'View all lotteries',
      color: 'text-gray-400',
      bgColor: 'hover:bg-gray-700',
      activeColor: 'bg-indigo-600 text-white'
    },
    {
      key: 'open' as FilterState,
      label: '🟢 Open',
      description: 'Accepting participants',
      color: 'text-green-400',
      bgColor: 'hover:bg-green-900/30',
      activeColor: 'bg-green-600 text-white'
    },
    {
      key: 'drawing' as FilterState,
      label: '🔄 Drawing',
      description: 'VRF in progress',
      color: 'text-yellow-400',
      bgColor: 'hover:bg-yellow-900/30',
      activeColor: 'bg-yellow-600 text-white'
    },
    {
      key: 'completed' as FilterState,
      label: '✅ Completed',
      description: 'Already have winner',
      color: 'text-blue-400',
      bgColor: 'hover:bg-blue-900/30',
      activeColor: 'bg-blue-600 text-white'
    },
    {
      key: 'cancelled' as FilterState,
      label: '❌ Cancelled',
      description: 'Cancelled lotteries',
      color: 'text-red-400',
      bgColor: 'hover:bg-red-900/30',
      activeColor: 'bg-red-600 text-white'
    }
  ];

  return (
    <div className="w-72 bg-gray-900 border-r border-gray-700 p-4 h-full flex-shrink-0 overflow-y-auto">
      <div className="mb-6">
        <h3 className="text-lg font-bold text-white mb-2">Filter Lotteries</h3>
        <p className="text-gray-400 text-xs">
          Organize by current state
        </p>
      </div>

      <div className="space-y-2">
        {filterOptions.map((option) => {
          const isActive = activeFilter === option.key;
          const count = lotteryCounts[option.key] || 0;
          
          return (
            <button
              key={option.key}
              onClick={() => onFilterChange(option.key)}
              className={`
                w-full text-left p-3 rounded-lg transition-all duration-200 border
                ${isActive 
                  ? `${option.activeColor} border-transparent shadow-lg` 
                  : `bg-gray-800 border-gray-700 ${option.bgColor} hover:border-gray-600`
                }
              `}
            >
              <div className="flex items-center justify-between mb-1">
                <span className={`font-medium ${isActive ? 'text-white' : option.color}`}>
                  {option.label}
                </span>
                <span className={`
                  text-xs px-2 py-1 rounded-full font-medium
                  ${isActive 
                    ? 'bg-white/20 text-white' 
                    : 'bg-gray-700 text-gray-300'
                  }
                `}>
                  {count}
                </span>
              </div>
              <p className={`
                text-sm 
                ${isActive ? 'text-white/80' : 'text-gray-500'}
              `}>
                {option.description}
              </p>
            </button>
          );
        })}
      </div>

      {/* Stats Section */}
      <div className="mt-8 p-4 bg-gray-800 rounded-lg border border-gray-700">
        <h4 className="text-white font-medium mb-3">📊 Statistics</h4>
        <div className="space-y-2 text-sm">
          <div className="flex justify-between">
            <span className="text-gray-400">Total lotteries:</span>
            <span className="text-white font-medium">{lotteryCounts.all}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-400">Active:</span>
            <span className="text-green-400 font-medium">{lotteryCounts.open}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-400">Completed:</span>
            <span className="text-blue-400 font-medium">{lotteryCounts.completed}</span>
          </div>
        </div>
      </div>
    </div>
  );
}