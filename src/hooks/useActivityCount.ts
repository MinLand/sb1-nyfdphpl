import { useState, useEffect } from 'react';
import { useGameStore } from '../store/gameStore';

export const useActivityCount = () => {
  const [activityCount, setActivityCount] = useState(0);
  const [loading, setLoading] = useState(true);
  const { currentRound, players } = useGameStore();
  const companyType = players.companyA ? 'A' : 'D';
  const activityLimit = companyType === 'A' ? 4 : 3;

  useEffect(() => {
    // Reset activity count when round changes
    setActivityCount(0);
    setLoading(false);
  }, [currentRound]);

  return { 
    activityCount, 
    loading,
    activityLimit,
    isLimitReached: activityCount >= activityLimit,
    incrementCount: () => setActivityCount(prev => Math.min(prev + 1, activityLimit))
  };
};