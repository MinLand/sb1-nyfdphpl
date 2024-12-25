import React from 'react';
import { MarketInsight } from '../../../../services/marketResearchService';

interface MarketShareSummaryProps {
  data: MarketInsight[];
}

export const MarketShareSummary: React.FC<MarketShareSummaryProps> = ({ data }) => {
  const totalMarketShare = data.reduce(
    (acc, insight) => ({
      drugA: acc.drugA + insight.drugAAdoption,
      drugD: acc.drugD + insight.drugDAdoption,
      traditional: acc.traditional + insight.traditionalTreatmentAdoption
    }),
    { drugA: 0, drugD: 0, traditional: 0 }
  );

  const averageShare = {
    drugA: totalMarketShare.drugA / (data.length || 1),
    drugD: totalMarketShare.drugD / (data.length || 1),
    traditional: totalMarketShare.traditional / (data.length || 1)
  };

  return (
    <div className="bg-gray-50 p-4 rounded-lg">
      <h4 className="text-base font-medium mb-3">Market Share Overview</h4>
      <div className="grid grid-cols-3 gap-4">
        <div>
          <p className="text-sm text-gray-600">Drug A Market Share</p>
          <p className="text-lg font-semibold text-blue-600">{averageShare.drugA.toFixed(1)}%</p>
        </div>
        <div>
          <p className="text-sm text-gray-600">Drug D Market Share</p>
          <p className="text-lg font-semibold text-green-600">{averageShare.drugD.toFixed(1)}%</p>
        </div>
        <div>
          <p className="text-sm text-gray-600">Traditional Treatments</p>
          <p className="text-lg font-semibold text-gray-600">{averageShare.traditional.toFixed(1)}%</p>
        </div>
      </div>
    </div>
  );
};