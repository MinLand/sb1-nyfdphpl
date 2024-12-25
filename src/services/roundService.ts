import { supabase } from '../lib/supabase';

export const advanceRound = async (roomId: string): Promise<void> => {
  try {
    const { error } = await supabase
      .rpc('advance_game_round', {
        p_room_id: roomId
      });

    if (error) throw error;
  } catch (error) {
    console.error('Error advancing round:', error);
    throw error;
  }
};

export const getCurrentRound = async (roomId: string): Promise<number> => {
  try {
    const { data, error } = await supabase
      .from('rooms')
      .select('current_round')
      .eq('id', roomId)
      .single();

    if (error) throw error;
    return data.current_round;
  } catch (error) {
    console.error('Error getting current round:', error);
    throw error;
  }
};