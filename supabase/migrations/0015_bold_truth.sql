/*
  # Add round tracking and game end functionality

  1. New Tables
    - `game_rounds` table to track round progress
      - `id` (uuid, primary key)
      - `room_id` (references rooms)
      - `round_number` (integer)
      - `status` (text: 'active', 'completed')
      - `created_at` (timestamp)

  2. Changes
    - Add round tracking to rooms table
    - Add game status tracking

  3. Security
    - Enable RLS
    - Add policies for authenticated users
*/

-- Create game_rounds table
CREATE TABLE IF NOT EXISTS game_rounds (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id),
  round_number integer NOT NULL DEFAULT 1,
  status text NOT NULL CHECK (status IN ('active', 'completed')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(room_id, round_number)
);

-- Add current_round to rooms
ALTER TABLE rooms 
ADD COLUMN IF NOT EXISTS current_round integer DEFAULT 1,
ADD COLUMN IF NOT EXISTS game_status text DEFAULT 'in_progress' 
  CHECK (game_status IN ('in_progress', 'completed'));

-- Enable RLS
ALTER TABLE game_rounds ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can read their room's rounds"
  ON game_rounds
  FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

CREATE POLICY "Users can insert rounds in their room"
  ON game_rounds
  FOR INSERT
  TO authenticated
  WITH CHECK (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

-- Function to advance game round
CREATE OR REPLACE FUNCTION advance_game_round(
  p_room_id text
) RETURNS void AS $$
DECLARE
  v_current_round integer;
BEGIN
  -- Get current round
  SELECT current_round INTO v_current_round
  FROM rooms
  WHERE id = p_room_id;

  -- Mark current round as completed
  UPDATE game_rounds
  SET status = 'completed'
  WHERE room_id = p_room_id AND round_number = v_current_round;

  -- Increment round if not at max
  IF v_current_round < 12 THEN
    UPDATE rooms
    SET current_round = current_round + 1
    WHERE id = p_room_id;

    -- Create new round
    INSERT INTO game_rounds (room_id, round_number, status)
    VALUES (p_room_id, v_current_round + 1, 'active');
  ELSE
    -- End game
    UPDATE rooms
    SET game_status = 'completed'
    WHERE id = p_room_id;
  END IF;
END;
$$ LANGUAGE plpgsql;