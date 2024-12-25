import React from 'react';
import { Building2, Briefcase } from 'lucide-react';

interface CompanySelectionProps {
  onSelect: (company: 'A' | 'D') => void;
}

export const CompanySelection: React.FC<CompanySelectionProps> = ({ onSelect }) => {
  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-800">Select Your Company</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <button
          onClick={() => onSelect('A')}
          className="flex items-center gap-4 p-6 bg-blue-50 border-2 border-blue-200 rounded-lg hover:bg-blue-100 transition-colors"
        >
          <Building2 className="w-8 h-8 text-blue-600" />
          <div className="text-left">
            <h3 className="font-medium text-blue-900">Company A</h3>
            <p className="text-sm text-blue-600">Specializes in Drug A</p>
          </div>
        </button>
        
        <button
          onClick={() => onSelect('D')}
          className="flex items-center gap-4 p-6 bg-green-50 border-2 border-green-200 rounded-lg hover:bg-green-100 transition-colors"
        >
          <Briefcase className="w-8 h-8 text-green-600" />
          <div className="text-left">
            <h3 className="font-medium text-green-900">Company D</h3>
            <p className="text-sm text-green-600">Specializes in Drug D</p>
          </div>
        </button>
      </div>
    </div>
  );
};