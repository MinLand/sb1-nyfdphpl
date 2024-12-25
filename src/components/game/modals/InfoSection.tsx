import React from 'react';

interface InfoSectionProps {
  title: string;
  content: string | string[];
}

export const InfoSection: React.FC<InfoSectionProps> = ({ title, content }) => {
  return (
    <section className="space-y-2">
      <h3 className="text-lg font-semibold text-gray-800">{title}</h3>
      {Array.isArray(content) ? (
        <ul className="list-disc list-inside space-y-1 text-gray-600">
          {content.map((item, index) => (
            <li key={index}>{item}</li>
          ))}
        </ul>
      ) : (
        <p className="text-gray-600">{content}</p>
      )}
    </section>
  );
};