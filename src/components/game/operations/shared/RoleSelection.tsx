import React from 'react';
import { Mic, Users, ArrowLeft } from 'lucide-react';

interface RoleSelectionProps {
  onSelect: (role: 'speaker' | 'attendee') => void;
  onBack: () => void;
}

export const RoleSelection: React.FC<RoleSelectionProps> = ({ onSelect, onBack }) => {
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <button onClick={onBack} className="p-1 hover:bg-gray-100 rounded-full">
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h3 className="text-lg font-medium text-gray-900">Select Role</h3>
      </div>
      <div className="grid grid-cols-2 gap-4">
        <button
          onClick={() => onSelect('speaker')}
          className="flex flex-col items-center gap-2 p-6 border rounded-lg hover:bg-gray-50 transition-colors"
        >
          <Mic className="w-8 h-8 text-blue-500" />
          <span className="font-medium">Speaker</span>
        </button>
        <button
          onClick={() => onSelect('attendee')}
          className="flex flex-col items-center gap-2 p-6 border rounded-lg hover:bg-gray-50 transition-colors"
        >
          <Users className="w-8 h-8 text-green-500" />
          <span className="font-medium">Attendee</span>
        </button>
      </div>
    </div>
  );
};