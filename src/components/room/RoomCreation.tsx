import React, { useState } from 'react';
import { CompanySelection } from './CompanySelection';
import { createRoom } from '../../services/roomService';
import { useGameStore } from '../../store/gameStore';
import { useAuth } from '../../hooks/useAuth';

export const RoomCreation: React.FC = () => {
  const [isSelecting, setIsSelecting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { user } = useAuth();
  const setRoomId = useGameStore((state) => state.setRoomId);
  const joinGame = useGameStore((state) => state.joinGame);

  const handleCompanySelect = async (company: 'A' | 'D') => {
    try {
      setError(null);
      if (!user) {
        throw new Error('Please sign in to create a room');
      }

      const room = await createRoom(company);
      setRoomId(room.id);
      joinGame(user.id, company);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to create room';
      setError(message);
      console.error('Failed to create room:', error);
    }
  };

  if (isSelecting) {
    return (
      <div className="space-y-4">
        <CompanySelection onSelect={handleCompanySelect} />
        {error && (
          <div className="p-3 text-sm text-red-600 bg-red-50 rounded-lg">
            {error}
          </div>
        )}
      </div>
    );
  }

  return (
    <button
      onClick={() => setIsSelecting(true)}
      className="flex items-center gap-2 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
    >
      Create Room
    </button>
  );
};