/*
  # Add doctor availability tracking

  1. New Tables
    - `doctor_availability`
      - `id` (uuid, primary key)
      - `room_id` (text, references rooms)
      - `doctor_id` (text)
      - `week_number` (integer)
      - `is_available` (boolean)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on `doctor_availability` table
    - Add policies for authenticated users to read and modify availability
*/

-- Create doctor_availability table
CREATE TABLE IF NOT EXISTS doctor_availability (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id),
  doctor_id text NOT NULL,
  week_number integer NOT NULL,
  is_available boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  UNIQUE(room_id, doctor_id, week_number)
);

-- Enable RLS
ALTER TABLE doctor_availability ENABLE ROW LEVEL SECURITY;

-- Policies for doctor_availability
CREATE POLICY "Users can read their room's doctor availability"
  ON doctor_availability
  FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

CREATE POLICY "Users can modify doctor availability in their room"
  ON doctor_availability
  FOR ALL
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ))
  WITH CHECK (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));