import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import type { MarketResearchData } from '../services/marketResearchService';

export const useMarketResearchData = (roomId: string, roundNumber: number) => {
  const [data, setData] = useState<MarketResearchData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const { data, error } = await supabase
          .from('market_research_data')
          .select(`
            id,
            hospitalId: hospital_id,
            potentialPatients: potential_patients,
            biologicalUsageRate: biological_usage_rate,
            drugAShare: drug_a_share,
            drugDShare: drug_d_share,
            hospitals (
              name
            )
          `)
          .eq('room_id', roomId)
          .eq('round_number', roundNumber);

        if (error) throw error;
        setData(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : '获取市场研究数据失败');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [roomId, roundNumber]);

  return { data, loading, error };
};