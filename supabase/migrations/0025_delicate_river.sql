/*
  # Fix player actions table and policies

  1. Changes
    - Recreate player_actions table with proper constraints
    - Add proper RLS policies
    - Add function to safely record player actions
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can read their room's actions" ON player_actions;
DROP POLICY IF EXISTS "Users can create actions for their company" ON player_actions;

-- Create new table with proper constraints
CREATE TABLE IF NOT EXISTS player_actions_new (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id) NOT NULL,
  round_number integer NOT NULL,
  company_id text NOT NULL CHECK (company_id IN ('A', 'D')),
  action_type text NOT NULL CHECK (
    action_type IN ('conference', 'research', 'visit', 'event')
  ),
  target_id uuid REFERENCES doctors(id),
  impact_score numeric NOT NULL DEFAULT 0,
  cost numeric NOT NULL DEFAULT 0,
  topic text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Copy data if old table exists, handling timestamps properly
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'player_actions') THEN
    INSERT INTO player_actions_new (
      id,
      room_id,
      round_number,
      company_id,
      action_type,
      target_id,
      impact_score,
      cost,
      topic,
      created_at,
      updated_at
    )
    SELECT 
      id,
      room_id,
      round_number,
      company_id,
      action_type,
      target_id,
      impact_score,
      cost,
      topic,
      created_at,
      COALESCE(updated_at, created_at)
    FROM player_actions;
  END IF;
END $$;

-- Drop old table and rename new one
DROP TABLE IF EXISTS player_actions CASCADE;
ALTER TABLE player_actions_new RENAME TO player_actions;

-- Create proper RLS policies
ALTER TABLE player_actions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their room's actions"
  ON player_actions
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = player_actions.room_id
      AND (rooms.company_a_player = auth.uid() OR rooms.company_d_player = auth.uid())
    )
  );

CREATE POLICY "Users can create actions for their company"
  ON player_actions
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_id
      AND (
        (company_id = 'A' AND rooms.company_a_player = auth.uid())
        OR 
        (company_id = 'D' AND rooms.company_d_player = auth.uid())
      )
    )
  );

-- Create function to safely record player actions
CREATE OR REPLACE FUNCTION record_player_action(
  p_room_id text,
  p_company_id text,
  p_round_number integer,
  p_action_type text,
  p_target_id uuid,
  p_cost numeric,
  p_topic text DEFAULT NULL
) RETURNS uuid AS $$
DECLARE
  v_action_id uuid;
BEGIN
  -- Validate company ownership
  IF NOT EXISTS (
    SELECT 1 FROM rooms
    WHERE id = p_room_id
    AND (
      (p_company_id = 'A' AND company_a_player = auth.uid())
      OR 
      (p_company_id = 'D' AND company_d_player = auth.uid())
    )
  ) THEN
    RAISE EXCEPTION 'Invalid company ownership';
  END IF;

  -- Insert action
  INSERT INTO player_actions (
    room_id,
    company_id,
    round_number,
    action_type,
    target_id,
    cost,
    topic,
    impact_score
  ) VALUES (
    p_room_id,
    p_company_id,
    p_round_number,
    p_action_type,
    p_target_id,
    p_cost,
    p_topic,
    CASE p_action_type
      WHEN 'conference' THEN CASE WHEN p_topic IS NOT NULL THEN 3 ELSE 1 END
      WHEN 'event' THEN 3
      WHEN 'research' THEN 2
      ELSE 1
    END
  ) RETURNING id INTO v_action_id;

  RETURN v_action_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;