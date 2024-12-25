import React from 'react';
import { Activity } from 'lucide-react';
import { useGameStore } from '../../../store/gameStore';
import { useActivityCount } from '../../../hooks/useActivityCount';

export const ActivityTracker: React.FC = () => {
  const { players } = useGameStore();
  const companyType = players.companyA ? 'A' : 'D';
  const activityLimit = companyType === 'A' ? 4 : 3;
  const { activityCount, loading } = useActivityCount();

  if (loading) {
    return (
      <div className="flex items-center gap-2">
        <Activity className="w-5 h-5 text-gray-400 animate-pulse" />
        <span className="text-gray-400">Loading...</span>
      </div>
    );
  }

  const percentage = (activityCount / activityLimit) * 100;
  
  return (
    <div className="flex items-center gap-3">
      <Activity className="w-5 h-5 text-blue-500" />
      <div className="flex flex-col">
        <div className="text-sm font-medium">
          Activities: {activityCount}/{activityLimit}
        </div>
        <div className="w-32 h-2 bg-gray-200 rounded-full mt-1">
          <div 
            className="h-full rounded-full bg-blue-500 transition-all duration-300"
            style={{ width: `${percentage}%` }}
          />
        </div>
      </div>
    </div>
  );
};