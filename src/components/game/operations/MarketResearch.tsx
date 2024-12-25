import React, { useState } from 'react';
import { Modal } from '../../common/Modal';
import { LineChart } from 'lucide-react';
import { useGameStore } from '../../../store/gameStore';
import { performMarketResearch, getMarketInsights, MarketInsight } from '../../../services/marketResearchService';
import { MarketResearchTable } from './MarketResearch/MarketResearchTable';
import { MarketShareSummary } from './MarketResearch/MarketShareSummary';
import { useActivityCount } from '../../../hooks/useActivityCount';

interface MarketResearchProps {
  isOpen: boolean;
  onClose: () => void;
}

export const MarketResearch: React.FC<MarketResearchProps> = ({ isOpen, onClose }) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [researchData, setResearchData] = useState<MarketInsight[]>([]);
  const [isResearchComplete, setIsResearchComplete] = useState(false);

  const { roomId, currentRound, players, remainingFunds } = useGameStore();
  const companyType = players.companyA ? 'A' : 'D';
  const playerFunds = remainingFunds[Object.keys(remainingFunds)[0]] || 0;
  const { incrementCount } = useActivityCount();

  const handleResearch = async () => {
    try {
      setLoading(true);
      setError(null);

      if (!roomId || !currentRound) {
        throw new Error('Room ID and round number are required');
      }

      if (playerFunds < 1000) {
        throw new Error('Insufficient funds');
      }

      await performMarketResearch(roomId, companyType, currentRound);
      const data = await getMarketInsights(roomId, currentRound);
      setResearchData(data);
      setIsResearchComplete(true);

      // Update funds
      useGameStore.getState().updateFunds(
        Object.keys(remainingFunds)[0],
        playerFunds - 1000
      );

      incrementCount();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to perform market research');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Market Research">
      <div className="space-y-6">
        {!isResearchComplete ? (
          <div className="text-center space-y-6">
            <div className="flex justify-center">
              <LineChart className="w-12 h-12 text-blue-500" />
            </div>
            <h3 className="text-lg font-medium">Conduct Market Research (Cost: $1,000)</h3>
            <div className="flex justify-center gap-4">
              <button
                onClick={handleResearch}
                disabled={loading || playerFunds < 1000}
                className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
              >
                {loading ? 'Processing...' : 'Start Research'}
              </button>
              <button
                onClick={onClose}
                disabled={loading}
                className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
              >
                Cancel
              </button>
            </div>
          </div>
        ) : (
          <div className="space-y-6">
            <MarketShareSummary data={researchData} />
            <MarketResearchTable data={researchData} />
          </div>
        )}

        {error && (
          <div className="p-3 text-sm text-red-600 bg-red-50 rounded-lg">
            {error}
          </div>
        )}
      </div>
    </Modal>
  );
};