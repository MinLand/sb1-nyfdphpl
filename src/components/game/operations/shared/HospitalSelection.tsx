import React from 'react';
import { Building } from 'lucide-react';
import { supabase } from '../../../../lib/supabase';

interface Hospital {
  id: string;
  name: string;
  patient_count: number;
}

interface HospitalSelectionProps {
  onSelect: (hospitalId: string) => void;
  onBack?: () => void;
}

export const HospitalSelection: React.FC<HospitalSelectionProps> = ({ onSelect, onBack }) => {
  const [hospitals, setHospitals] = React.useState<Hospital[]>([]);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    const fetchHospitals = async () => {
      const { data, error } = await supabase
        .from('hospitals')
        .select('*');
      
      if (error) throw error;
      setHospitals(data);
      setLoading(false);
    };

    fetchHospitals();
  }, []);

  if (loading) {
    return <div>Loading hospitals...</div>;
  }

  return (
    <div className="space-y-4">
      <h3 className="text-lg font-medium text-gray-900">Select Hospital</h3>
      <div className="grid grid-cols-1 gap-3">
        {hospitals.map((hospital) => (
          <button
            key={hospital.id}
            onClick={() => onSelect(hospital.id)}
            className="flex items-center gap-3 p-4 text-left border rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Building className="w-5 h-5 text-gray-500" />
            <div>
              <p className="font-medium text-gray-900">{hospital.name}</p>
              <p className="text-sm text-gray-500">
                Outpatient volume: {hospital.patient_count}
              </p>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
};