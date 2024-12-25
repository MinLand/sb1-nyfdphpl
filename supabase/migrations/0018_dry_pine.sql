/*
  # Update Game Configuration
  
  1. Changes
    - Update advance_game_round function to support 15 rounds
    - Add game configuration table
*/

-- Update advance_game_round function to support 15 rounds
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
  IF v_current_round < 15 THEN
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

-- Create game_config table
CREATE TABLE IF NOT EXISTS game_config (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id),
  total_rounds integer NOT NULL DEFAULT 15,
  initial_funds integer NOT NULL DEFAULT 60000,
  created_at timestamptz DEFAULT now(),
  UNIQUE(room_id)
);

-- Enable RLS
ALTER TABLE game_config ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can read their room's config"
  ON game_config
  FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

-- Insert default config for existing rooms
INSERT INTO game_config (room_id, total_rounds, initial_funds)
SELECT id, 15, 60000
FROM rooms
ON CONFLICT (room_id) DO UPDATE
SET 
  total_rounds = EXCLUDED.total_rounds,
  initial_funds = EXCLUDED.initial_funds;