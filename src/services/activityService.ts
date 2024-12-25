import { supabase } from '../lib/supabase';

export type ActivityType = 'conference' | 'research' | 'visit' | 'event';

interface ActivityParams {
  roomId: string;
  companyId: 'A' | 'D';
  roundNumber: number;
  actionType: ActivityType;
  cost: number;
  doctorName?: string;
  topic?: string;
}

export const recordActivity = async ({
  roomId,
  companyId,
  roundNumber,
  actionType,
  cost,
  doctorName = 'na',
  topic = 'na'
}: ActivityParams): Promise<void> => {
  try {
    if (!roomId) {
      throw new Error('Room ID is required');
    }

    const { error } = await supabase.rpc('record_player_action', {
      p_action_type: actionType,
      p_company_id: companyId,
      p_cost: cost,
      p_doctor_name: doctorName,
      p_room_id: roomId,
      p_round_number: roundNumber,
      p_topic: topic
    });

    if (error) throw error;
  } catch (error) {
    console.error('Error recording activity:', error);
    throw error;
  }
};