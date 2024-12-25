import React from 'react';
import { SectionContent } from '../types';
import { InfoSection } from './InfoSection';

interface ModalContentProps {
  sections: SectionContent[];
}

export const ModalContent: React.FC<ModalContentProps> = ({ sections }) => (
  <div className="space-y-6 max-h-[70vh] overflow-y-auto">
    {sections.map((section, index) => (
      <InfoSection
        key={`${section.title}-${index}`}
        title={section.title}
        content={section.content}
      />
    ))}
  </div>
);