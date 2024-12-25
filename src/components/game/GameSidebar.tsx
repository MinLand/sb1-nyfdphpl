import React, { useState } from 'react';
import { BookOpen, Building2, Activity, Stethoscope, Building } from 'lucide-react';
import { GameRules } from './modals/GameRules';
import { MarketInfo } from './modals/MarketInfo';
import { DiseaseInfo } from './modals/DiseaseInfo';
import { HospitalInfo } from './modals/HospitalInfo';
import { CompanyInsights } from './modals/CompanyInsights';

export const GameSidebar: React.FC = () => {
  const [activeModal, setActiveModal] = useState<string | null>(null);

  const buttons = [
    { id: 'rules', icon: BookOpen, label: 'Game Rules' },
    { id: 'market', icon: Building2, label: 'Market Info' },
    { id: 'disease', icon: Stethoscope, label: 'Disease Info' },
    { id: 'hospital', icon: Building, label: 'Hospital Info' },
    { id: 'insights', icon: Activity, label: 'Insights' },
  ] as const;

  return (
    <aside className="w-64 bg-white shadow-sm h-screen p-4">
      <nav className="space-y-2">
        {buttons.map(({ id, icon: Icon, label }) => (
          <button
            key={id}
            onClick={() => setActiveModal(id)}
            className="w-full flex items-center gap-3 px-4 py-3 text-left hover:bg-gray-50 rounded-lg transition-colors"
          >
            <Icon className="w-5 h-5 text-gray-600" />
            <span className="text-sm font-medium text-gray-700">{label}</span>
          </button>
        ))}
      </nav>

      <GameRules isOpen={activeModal === 'rules'} onClose={() => setActiveModal(null)} />
      <MarketInfo isOpen={activeModal === 'market'} onClose={() => setActiveModal(null)} />
      <DiseaseInfo isOpen={activeModal === 'disease'} onClose={() => setActiveModal(null)} />
      <HospitalInfo isOpen={activeModal === 'hospital'} onClose={() => setActiveModal(null)} />
      <CompanyInsights isOpen={activeModal === 'insights'} onClose={() => setActiveModal(null)} />
    </aside>
  );
};