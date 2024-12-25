import { supabase } from '../lib/supabase';
import { generateRoomId } from '../utils/roomUtils';
import { getCurrentUser } from './authService';

export const createRoom = async (company: 'A' | 'D') => {
  try {
    const user = await getCurrentUser();
    if (!user) {
      throw new Error('Authentication required');
    }

    const roomId = generateRoomId();
    const { data, error } = await supabase
      .from('rooms')
      .insert({
        id: roomId,
        status: 'waiting',
        ...(company === 'A' 
          ? { company_a_player: user.id }
          : { company_d_player: user.id })
      })
      .select()
      .single();

    if (error) {
      console.error('Database error:', error);
      throw new Error('Failed to create room');
    }

    return data;
  } catch (error) {
    console.error('Room creation error:', error);
    throw error;
  }
};