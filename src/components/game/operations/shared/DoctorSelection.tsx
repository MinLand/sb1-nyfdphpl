import React from 'react';
import { UserCircle, ArrowLeft } from 'lucide-react';
import { supabase } from '../../../../lib/supabase';

interface Doctor {
  id: string;
  name: string;
  title: string;
  knowledge_scores: Record<string, number>;
}

interface DoctorSelectionProps {
  hospitalId: string;
  onSelect: (doctorId: string) => void;
  onBack: () => void;
}

export const DoctorSelection: React.FC<DoctorSelectionProps> = ({ hospitalId, onSelect, onBack }) => {
  const [doctors, setDoctors] = React.useState<Doctor[]>([]);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    const fetchDoctors = async () => {
      const { data, error } = await supabase
        .from('doctors')
        .select('*')
        .eq('hospital_id', hospitalId);
      
      if (error) throw error;
      setDoctors(data);
      setLoading(false);
    };

    fetchDoctors();
  }, [hospitalId]);

  if (loading) {
    return <div>Loading doctors...</div>;
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <button onClick={onBack} className="p-1 hover:bg-gray-100 rounded-full">
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h3 className="text-lg font-medium text-gray-900">Select Doctor</h3>
      </div>
      <div className="grid grid-cols-1 gap-3">
        {doctors.map((doctor) => (
          <button
            key={doctor.id}
            onClick={() => onSelect(doctor.id)}
            className="flex items-center gap-3 p-4 text-left border rounded-lg hover:bg-gray-50 transition-colors"
          >
            <UserCircle className="w-5 h-5 text-gray-500" />
            <div>
              <p className="font-medium text-gray-900">{doctor.name}</p>
              <p className="text-sm text-gray-500">{doctor.title}</p>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
};