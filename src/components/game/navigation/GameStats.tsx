import React from 'react';
import { Clock, DollarSign, TrendingUp, PieChart } from 'lucide-react';
import { useGameStore } from '../../../store/gameStore';
import { formatCurrency } from '../../../utils/formatters';
import { ActivityTracker } from './ActivityTracker';
import { RoundTimer } from './RoundTimer';

export const GameStats: React.FC = () => {
  const { currentRound, totalRounds, remainingFunds } = useGameStore();
  const playerFunds = remainingFunds[Object.keys(remainingFunds)[0]] || 0;

  return (
    <div className="grid grid-cols-6 gap-4 p-4 border-t">
      <StatItem
        icon={<Clock className="w-5 h-5 text-blue-500" />}
        label="Round"
        value={`${currentRound}/${totalRounds}`}
      />
      <StatItem
        icon={<DollarSign className="w-5 h-5 text-green-500" />}
        label="Funds"
        value={formatCurrency(playerFunds)}
      />
      <StatItem
        icon={<TrendingUp className="w-5 h-5 text-purple-500" />}
        label="Annual Sales"
        value={formatCurrency(0)}
      />
      <StatItem
        icon={<PieChart className="w-5 h-5 text-indigo-500" />}
        label="Market Share"
        value="0%"
      />
      <div className="flex items-center">
        <ActivityTracker />
      </div>
      <div className="flex items-center">
        <RoundTimer />
      </div>
    </div>
  );
};

interface StatItemProps {
  icon: React.ReactNode;
  label: string;
  value: string;
}

const StatItem: React.FC<StatItemProps> = ({ icon, label, value }) => (
  <div className="flex items-center gap-3">
    {icon}
    <div>
      <p className="text-sm text-gray-500">{label}</p>
      <p className="font-semibold">{value}</p>
    </div>
  </div>
);