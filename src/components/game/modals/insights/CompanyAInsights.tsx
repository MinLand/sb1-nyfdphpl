import React from 'react';
import { InfoSection } from '../components/InfoSection';

export const CompanyAInsights: React.FC = () => (
  <div className="space-y-6">
    <InfoSection
      title="Hospital A Performance"
      content={[
        "Dr. Shan (45) specializes in PID research and clinical work",
        "Strong academic focus on disease mechanisms and treatment targets",
        "Drug A well-established with good efficacy recognition",
        "Monthly injection schedule causing nursing staff strain",
        "Expected annual sales: 6,333 units"
      ]}
    />
    
    <InfoSection
      title="Hospital B Status"
      content={[
        "New department head actively developing PID specialty",
        "20% of moderate-severe PID patients try Drug A",
        "Marketing focuses on rapid onset vs traditional treatments",
        "Expected annual sales: 2,080 units"
      ]}
    />
    
    <InfoSection
      title="Regional Hospitals (C/D/E/F)"
      content={[
        "Similar situations across regional hospitals",
        "Limited biological agent adoption",
        "Marketing emphasizes safety to reduce usage concerns",
        "Some doctors trained at San Fan First Hospital",
        "Combined expected annual sales: 2,880 units"
      ]}
    />
  </div>
);