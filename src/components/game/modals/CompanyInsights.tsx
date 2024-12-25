import React from 'react';
import { Modal } from '../../common/Modal';
import { CompanyAInsights } from './insights/CompanyAInsights';
import { CompanyDInsights } from './insights/CompanyDInsights';
import { useGameStore } from '../../../store/gameStore';

interface CompanyInsightsProps {
  isOpen: boolean;
  onClose: () => void;
}

export const CompanyInsights: React.FC<CompanyInsightsProps> = ({ isOpen, onClose }) => {
  const { players } = useGameStore();
  const isCompanyA = !!players.companyA;

  return (
    <Modal isOpen={isOpen} onClose={onClose} title={`${isCompanyA ? 'Company A' : 'Company D'} Insights`}>
      <div className="space-y-6 max-h-[70vh] overflow-y-auto">
        {isCompanyA ? <CompanyAInsights /> : <CompanyDInsights />}
      </div>
    </Modal>
  );
};