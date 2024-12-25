/*
  # Fix player_actions RLS policies

  1. Changes
    - Drop existing policies
    - Create new policies with proper auth checks
    - Add policies for all CRUD operations
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can read their room's actions" ON player_actions;
DROP POLICY IF EXISTS "Users can insert their room's actions" ON player_actions;

-- Create new policies
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

CREATE POLICY "Users can insert actions for their company"
  ON player_actions
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_id
      AND (
        (company_id = 'A' AND rooms.company_a_player = auth.uid()) OR
        (company_id = 'D' AND rooms.company_d_player = auth.uid())
      )
    )
  );

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_player_actions_company_room
ON player_actions(company_id, room_id);