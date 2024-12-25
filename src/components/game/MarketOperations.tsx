import React, { useState } from 'react';
import { OperationButton } from './operations/OperationButton';
import { operations } from './operations/operationsConfig';
import { CityConference } from './operations/CityConference';
import { ExternalEvents } from './operations/ExternalEvents';
import { MarketResearch } from './operations/MarketResearch';
import { useGameStore } from '../../store/gameStore';
import { useActivityCount } from '../../hooks/useActivityCount';

export const MarketOperations: React.FC = () => {
  const [showConference, setShowConference] = useState(false);
  const [showExternalEvents, setShowExternalEvents] = useState(false);
  const [showMarketResearch, setShowMarketResearch] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const { remainingFunds, players } = useGameStore();
  const { activityCount, loading } = useActivityCount();
  
  const playerFunds = remainingFunds[Object.keys(remainingFunds)[0]] || 0;
  const companyType = players.companyA ? 'A' : 'D';
  const activityLimit = companyType === 'A' ? 4 : 3;

  const handleOperationClick = (operationId: string) => {
    if (activityCount >= activityLimit) {
      setError('You have reached the activity limit for this round');
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
            disabled={op.cost > playerFunds || activityCount >= activityLimit}
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