import React from 'react';
import { InfoSection } from '../components/InfoSection';

export const CompanyDInsights: React.FC = () => (
  <div className="space-y-6">
    <InfoSection
      title="Hospital A Initial Assessment"
      content={[
        "Dr. Shan has strong academic background in PID",
        "Drug A well-established with recognized efficacy",
        "Some natural Drug D sales despite no active promotion",
        "Current sales: 56 units"
      ]}
    />
    
    <InfoSection
      title="Hospital B Situation"
      content={[
        "Department head new to PID field",
        "Multiple PID specialty clinics established",
        "Traditional treatments still dominant",
        "Current sales: 116 units"
      ]}
    />
    
    <InfoSection
      title="Regional Hospitals (C/D/E/F)"
      content={[
        "Limited PID research and publications",
        "No dedicated Company A representatives",
        "Immunosuppressants remain primary treatment",
        "Sales potential to be determined based on changing doctor perspectives"
      ]}
    />
  </div>
);