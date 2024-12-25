import React from 'react';
import { RoomLobby } from '../room/RoomLobby';
import { GameBoard } from './GameBoard';
import { GameEnd } from './GameEnd';
import { useGameStore } from '../../store/gameStore';
import { RoomCreation } from '../room/RoomCreation';
import { RoomJoin } from '../room/RoomJoin';

export const GameLayout: React.FC = () => {
  const { roomId, players, currentRound, totalRounds } = useGameStore();
  const gameStarted = players.companyA && players.companyD;
  const gameEnded = currentRound >= totalRounds;

  if (!roomId) {
    return (
      <div className="min-h-screen bg-gray-50 p-8">
        <div className="max-w-4xl mx-auto grid gap-8 md:grid-cols-2">
          <div className="space-y-6">
            <h2 className="text-2xl font-bold">Create New Game</h2>
            <RoomCreation />
          </div>
          <div className="space-y-6">
            <h2 className="text-2xl font-bold">Join Existing Game</h2>
            <RoomJoin />
          </div>
        </div>
      </div>
    );
  }

  if (gameEnded) {
    return <GameEnd />;
  }

  if (!gameStarted) {
    return <RoomLobby />;
  }

  return <GameBoard />;
};