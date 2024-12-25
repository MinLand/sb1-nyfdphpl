/*
  # Add Insert Policies for Game Tables
  
  1. Changes
    - Add insert policies for rooms table
    - Add insert policies for market_share table
    - Add update policies for rooms table
  
  2. Security
    - Allow authenticated users to create rooms
    - Allow room players to update their rooms
    - Allow players to insert market share data for their rooms
*/

-- Add insert policies for rooms
CREATE POLICY "Users can create rooms"
  ON rooms
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = company_a_player OR
    auth.uid() = company_d_player
  );

-- Add update policy for rooms
CREATE POLICY "Players can update their rooms"
  ON rooms
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = company_a_player OR
    auth.uid() = company_d_player
  )
  WITH CHECK (
    auth.uid() = company_a_player OR
    auth.uid() = company_d_player
  );

-- Add insert policy for market_share
CREATE POLICY "Players can insert market share data"
  ON market_share
  FOR INSERT
  TO authenticated
  WITH CHECK (
    room_id IN (
      SELECT id FROM rooms
      WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
    )
  );