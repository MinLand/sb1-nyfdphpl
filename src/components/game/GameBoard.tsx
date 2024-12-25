import React from 'react';
import { GameHeader } from './navigation/GameHeader';
import { GameSidebar } from './GameSidebar';
import { MarketOperations } from './MarketOperations';

export const GameBoard: React.FC = () => {
  return (
    <div className="min-h-screen bg-gray-50">
      <GameHeader />
      <div className="flex">
        <GameSidebar />
        <main className="flex-1 p-6">
          <MarketOperations />
        </main>
      </div>
    </div>
  );
};