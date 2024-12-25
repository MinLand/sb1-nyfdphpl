import React from 'react';
import { Timer } from 'lucide-react';
import { useRoundTimer } from '../../../hooks/useRoundTimer';

export const RoundTimer: React.FC = () => {
  const { minutes, seconds, timeLeft, totalTime } = useRoundTimer();
  const progress = (timeLeft / totalTime) * 100;
  
  const getColorClass = () => {
    if (timeLeft <= 60) return 'text-red-600'; // Last minute
    if (timeLeft <= 120) return 'text-yellow-600'; // Last 2 minutes
    return 'text-blue-600';
  };

  return (
    <div className="flex items-center gap-3">
      <Timer className={`w-5 h-5 ${getColorClass()}`} />
      <div className="flex flex-col">
        <div className={`text-sm font-medium ${getColorClass()}`}>
          {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}
        </div>
        <div className="w-32 h-2 bg-gray-200 rounded-full mt-1">
          <div 
            className={`h-full rounded-full transition-all duration-300 ${getColorClass().replace('text-', 'bg-')}`}
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>
    </div>
  );
};