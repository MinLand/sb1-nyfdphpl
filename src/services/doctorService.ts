import { supabase } from '../lib/supabase';

export const checkDoctorAvailability = async (
  roomId: string,
  doctorId: string,
  roundNumber: number
): Promise<boolean> => {
  // First check if availability record exists
  const { data, error } = await supabase
    .from('doctor_availability')
    .select('is_available')
    .eq('room_id', roomId)
    .eq('doctor_id', doctorId)
    .eq('round_number', roundNumber)
    .single();

  if (error) {
    if (error.code === 'PGRST116') { // Record not found
      // Create new availability record
      const { error: insertError } = await supabase
        .from('doctor_availability')
        .insert({
          room_id: roomId,
          doctor_id: doctorId,
          round_number: roundNumber,
          is_available: true
        });
      
      if (insertError) throw insertError;
      return true;
    }
    throw error;
  }

  return data?.is_available ?? false;
};

export const setDoctorAvailability = async (
  roomId: string,
  doctorId: string,
  roundNumber: number,
  isAvailable: boolean
): Promise<void> => {
  const { error } = await supabase
    .from('doctor_availability')
    .upsert({
      room_id: roomId,
      doctor_id: doctorId,
      round_number: roundNumber,
      is_available: isAvailable
    });

  if (error) throw error;
};