import React from 'react';
import { MarketInsight } from '../../../../services/marketResearchService';

interface MarketResearchTableProps {
  data: MarketInsight[];
}

export const MarketResearchTable: React.FC<MarketResearchTableProps> = ({ data }) => {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Hospital</th>
            <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Total Patients</th>
            <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Drug A Share</th>
            <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Drug D Share</th>
            <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Traditional</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {data.map((insight) => (
            <tr key={insight.id}>
              <td className="px-4 py-3 text-sm text-gray-900">{insight.hospitals.name}</td>
              <td className="px-4 py-3 text-sm text-right">{insight.totalPatients}</td>
              <td className="px-4 py-3 text-sm text-right">{insight.drugAAdoption}%</td>
              <td className="px-4 py-3 text-sm text-right">{insight.drugDAdoption}%</td>
              <td className="px-4 py-3 text-sm text-right">{insight.traditionalTreatmentAdoption}%</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};