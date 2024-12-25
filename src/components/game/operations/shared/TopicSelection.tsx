import React from 'react';
import { ArrowLeft } from 'lucide-react';
import { supabase } from '../../../../lib/supabase';

interface Topic {
  id: string;
  title: string;
  content: string;
}

interface TopicSelectionProps {
  companyId: 'A' | 'D';
  onSelect: (topicId: string) => void;
  onBack: () => void;
}

export const TopicSelection: React.FC<TopicSelectionProps> = ({ companyId, onSelect, onBack }) => {
  const [topics, setTopics] = React.useState<Topic[]>([]);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    const fetchTopics = async () => {
      const { data, error } = await supabase
        .from('topics')
        .select('*')
        .eq('company', companyId);
      
      if (error) throw error;
      setTopics(data);
      setLoading(false);
    };

    fetchTopics();
  }, [companyId]);

  if (loading) {
    return <div>Loading topics...</div>;
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <button onClick={onBack} className="p-1 hover:bg-gray-100 rounded-full">
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h3 className="text-lg font-medium text-gray-900">Select Topic</h3>
      </div>
      <div className="grid grid-cols-1 gap-3">
        {topics.map((topic) => (
          <button
            key={topic.id}
            onClick={() => onSelect(topic.id)}
            className="p-4 text-left border rounded-lg hover:bg-gray-50 transition-colors"
          >
            <p className="font-medium text-gray-900">{topic.title}</p>
            <p className="text-sm text-gray-500 mt-1">{topic.content}</p>
          </button>
        ))}
      </div>
    </div>
  );
};