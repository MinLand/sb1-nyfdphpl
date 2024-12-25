import React from 'react';
import { LucideIcon } from 'lucide-react';

interface OperationButtonProps {
  name: string;
  cost: number;
  icon: LucideIcon;
  onClick: () => void;
}

export const OperationButton: React.FC<OperationButtonProps> = ({
  name,
  cost,
  icon: Icon,
  onClick,
}) => (
  <button
    onClick={onClick}
    className="flex items-center gap-4 p-6 bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow"
  >
    <Icon className="w-8 h-8 text-blue-500" />
    <div className="text-left">
      <h3 className="font-medium">{name}</h3>
      <p className="text-sm text-gray-500">Cost: ${cost}</p>
    </div>
  </button>
);