import React from 'react';
import { Trophy } from 'lucide-react';
import { useGameStore } from '../../store/gameStore';

export const GameEnd: React.FC = () => {
  const { marketShare } = useGameStore();

  // Calculate final market share
  const totalShare = Object.values(marketShare).reduce(
    (acc, { aDrug, dDrug }) => ({
      aDrug: acc.aDrug + aDrug,
      dDrug: acc.dDrug + dDrug
    }),
    { aDrug: 0, dDrug: 0 }
  );

  const winner = totalShare.aDrug > totalShare.dDrug ? 'A' : 'D';

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg shadow-xl p-8 max-w-2xl w-full text-center">
        <Trophy className="w-16 h-16 text-yellow-500 mx-auto mb-6" />
        <h1 className="text-3xl font-bold text-gray-900 mb-4">
          Game Over!
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          Company {winner} wins with {winner === 'A' ? totalShare.aDrug : totalShare.dDrug}% market share!
        </p>
        
        <div className="grid grid-cols-2 gap-8 mb-8">
          <div>
            <h2 className="text-lg font-semibold text-gray-800 mb-2">Company A</h2>
            <p className="text-3xl font-bold text-blue-600">{totalShare.aDrug.toFixed(1)}%</p>
          </div>
          <div>
            <h2 className="text-lg font-semibold text-gray-800 mb-2">Company D</h2>
            <p className="text-3xl font-bold text-green-600">{totalShare.dDrug.toFixed(1)}%</p>
          </div>
        </div>

        <button
          onClick={() => window.location.reload()}
          className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
        >
          Start New Game
        </button>
      </div>
    </div>
  );
};