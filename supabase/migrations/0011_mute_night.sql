/*
  # Add Doctor Availability Tracking
  
  1. Changes
    - Create doctor_availability table to track availability per round
    - Add default availability status for all doctors
    
  2. Security
    - Enable RLS
    - Add policies for authenticated users
*/

-- Drop existing policies if they exist
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Users can read their room's doctor availability" ON doctor_availability;
    DROP POLICY IF EXISTS "Users can update doctor availability in their room" ON doctor_availability;
    DROP POLICY IF EXISTS "Users can modify doctor availability in their room" ON doctor_availability;
EXCEPTION 
    WHEN undefined_object THEN null;
END $$;

-- Create doctor_availability table if it doesn't exist
CREATE TABLE IF NOT EXISTS doctor_availability (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id),
  doctor_id uuid REFERENCES doctors(id),
  round_number integer NOT NULL,
  is_available boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  UNIQUE(room_id, doctor_id, round_number)
);

-- Enable RLS
ALTER TABLE doctor_availability ENABLE ROW LEVEL SECURITY;

-- Create new policies
CREATE POLICY "Users can read their room's doctor availability"
  ON doctor_availability
  FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

CREATE POLICY "Users can update doctor availability in their room"
  ON doctor_availability
  FOR INSERT
  TO authenticated
  WITH CHECK (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

CREATE POLICY "Users can modify doctor availability in their room"
  ON doctor_availability
  FOR UPDATE
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));