import { useState, useEffect, useCallback } from 'react';
import { useGameStore } from '../store/gameStore';

const ROUND_DURATION = 5 * 60; // 5 minutes in seconds

export const useRoundTimer = () => {
  const [timeLeft, setTimeLeft] = useState(ROUND_DURATION);
  const { currentRound, advanceRound } = useGameStore();

  const handleAdvanceRound = useCallback(() => {
    advanceRound();
    setTimeLeft(ROUND_DURATION);
  }, [advanceRound]);

  useEffect(() => {
    setTimeLeft(ROUND_DURATION);
  }, [currentRound]);

  useEffect(() => {
    const timer = setInterval(() => {
      setTimeLeft((prevTime) => {
        if (prevTime <= 1) {
          handleAdvanceRound();
          return ROUND_DURATION;
        }
        return prevTime - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [handleAdvanceRound]);

  const minutes = Math.floor(timeLeft / 60);
  const seconds = timeLeft % 60;

  return {
    minutes,
    seconds,
    timeLeft,
    totalTime: ROUND_DURATION
  };
};