import { supabase } from '../lib/supabase';
import { recordActivity } from './activityService';

export interface MarketInsight {
  id: string;
  hospitalId: string;
  totalPatients: number;
  drugAAdoption: number;
  drugDAdoption: number;
  traditionalTreatmentAdoption: number;
  hospitals: {
    name: string;
  };
}

export const performMarketResearch = async (
  roomId: string,
  companyId: 'A' | 'D',
  roundNumber: number
): Promise<void> => {
  try {
    if (!roomId || !roundNumber) {
      throw new Error('Room ID and round number are required');
    }

    await recordActivity({
      roomId,
      companyId,
      roundNumber,
      actionType: 'research',
      cost: 1000
    });
  } catch (error) {
    console.error('Market research error:', error);
    throw error;
  }
};

export const getMarketInsights = async (
  roomId: string,
  roundNumber: number
): Promise<MarketInsight[]> => {
  try {
    if (!roomId || !roundNumber) {
      throw new Error('Room ID and round number are required');
    }

    const { data, error } = await supabase
      .from('market_insights')
      .select(`
        id,
        hospitalId: hospital_id,
        totalPatients: total_patients,
        drugAAdoption: drug_a_adoption,
        drugDAdoption: drug_d_adoption,
        traditionalTreatmentAdoption: traditional_treatment_adoption,
        hospitals (
          name
        )
      `)
      .eq('room_id', roomId)
      .eq('round_number', roundNumber)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching market insights:', error);
    throw error;
  }
};