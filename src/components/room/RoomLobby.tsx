import React from 'react';
import { Users } from 'lucide-react';
import { useGameStore } from '../../store/gameStore';

export const RoomLobby: React.FC = () => {
  const { roomId, players } = useGameStore();

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-semibold">Game Lobby</h2>
        <span className="text-sm text-gray-500">Room ID: {roomId}</span>
      </div>
      <div className="space-y-4">
        <div className="flex items-center gap-3">
          <Users className="w-5 h-5 text-blue-500" />
          <div>
            <p className="font-medium">Company A</p>
            <p className="text-sm text-gray-500">
              {players.companyA ? 'Player joined' : 'Waiting for player...'}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-3">
          <Users className="w-5 h-5 text-green-500" />
          <div>
            <p className="font-medium">Company D</p>
            <p className="text-sm text-gray-500">
              {players.companyD ? 'Player joined' : 'Waiting for player...'}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};