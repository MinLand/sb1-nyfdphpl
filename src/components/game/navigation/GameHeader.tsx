import React from 'react';
import { GameStats } from './GameStats';
import { MarketActions } from './MarketActions';

export const GameHeader: React.FC = () => {
  return (
    <header className="bg-white shadow-sm">
      <div className="max-w-7xl mx-auto">
        <MarketActions />
        <GameStats />
      </div>
    </header>
  );
};