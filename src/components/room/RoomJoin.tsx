import React, { useState } from 'react';
import { LogIn } from 'lucide-react';
import { useGameStore } from '../../store/gameStore';

export const RoomJoin: React.FC = () => {
  const [roomId, setRoomId] = useState('');
  const joinGame = useGameStore((state) => state.joinGame);

  const handleJoinRoom = async (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: Validate and join room in Supabase
    joinGame('temp-player-id', 'D'); // Temporary implementation
  };

  return (
    <form onSubmit={handleJoinRoom} className="space-y-4">
      <div>
        <label htmlFor="roomId" className="block text-sm font-medium text-gray-700">
          Room ID
        </label>
        <input
          id="roomId"
          type="text"
          value={roomId}
          onChange={(e) => setRoomId(e.target.value)}
          placeholder="Enter 6-digit room code"
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          pattern="[0-9]{6}"
          required
        />
      </div>
      <button
        type="submit"
        className="flex items-center justify-center gap-2 w-full px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
      >
        <LogIn className="w-5 h-5" />
        Join Room
      </button>
    </form>
  );
};