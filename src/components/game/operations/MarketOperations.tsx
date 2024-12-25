import React, { useState } from 'react';
import { OperationButton } from './OperationButton';
import { operations } from './operationsConfig';
import { CityConference } from './CityConference';
import { ExternalEvents } from './ExternalEvents';
import { MarketResearch } from './MarketResearch';
import { useGameStore } from '../../../store/gameStore';
import { useActivityCount } from '../../../hooks/useActivityCount';

export const MarketOperations: React.FC = () => {
  const [showConference, setShowConference] = useState(false);
  const [showExternalEvents, setShowExternalEvents] = useState(false);
  const [showMarketResearch, setShowMarketResearch] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const { remainingFunds, players } = useGameStore();
  const { activityCount, activityLimit, isLimitReached, loading } = useActivityCount();
  
  const playerFunds = remainingFunds[Object.keys(remainingFunds)[0]] || 0;

  const handleOperationClick = (operationId: string) => {
    if (isLimitReached) {
      setError(`You have reached the activity limit (${activityLimit}) for this round`);
      return;
    }

    setError(null);
    switch (operationId) {
      case 'city-conference':
        setShowConference(true);
        break;
      case 'external-events':
        setShowExternalEvents(true);
        break;
      case 'market-research':
        setShowMarketResearch(true);
        break;
    }
  };

  if (loading) {
    return <div className="p-4">Loading activities...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-lg font-semibold">
          Activities: {activityCount}/{activityLimit}
        </h2>
        {isLimitReached && (
          <button
            onClick={() => useGameStore.getState().advanceRound()}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            Finish Round
          </button>
        )}
      </div>

      {error && (
        <div className="p-3 text-sm text-red-600 bg-red-50 rounded-lg">
          {error}
        </div>
      )}

      <div className="grid grid-cols-2 gap-6">
        {operations.map((op) => (
          <OperationButton
            key={op.id}
            name={op.name}
            cost={op.cost}
            icon={op.icon}
            disabled={op.cost > playerFunds || isLimitReached}
            onClick={() => handleOperationClick(op.id)}
          />
        ))}
      </div>

      <CityConference
        isOpen={showConference}
        onClose={() => setShowConference(false)}
      />

      <ExternalEvents
        isOpen={showExternalEvents}
        onClose={() => setShowExternalEvents(false)}
      />

      <MarketResearch
        isOpen={showMarketResearch}
        onClose={() => setShowMarketResearch(false)}
      />
    </div>
  );
};