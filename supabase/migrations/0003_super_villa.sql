/*
  # Update Authentication System
  
  1. Changes
    - Remove all dependent policies
    - Update room table to use auth.users
    - Drop accounts table
    - Recreate all policies
  
  2. Security
    - Policies updated to work with auth.users
    - Maintain RLS throughout migration
*/

-- First drop ALL dependent policies in correct order
DROP POLICY IF EXISTS "Users can read market share for their rooms" ON market_share;
DROP POLICY IF EXISTS "Players can insert market share data" ON market_share;
DROP POLICY IF EXISTS "Users can read rooms they are in" ON rooms;
DROP POLICY IF EXISTS "Users can create rooms" ON rooms;
DROP POLICY IF EXISTS "Players can update their rooms" ON rooms;

-- Drop foreign key constraints safely
ALTER TABLE rooms 
  DROP CONSTRAINT IF EXISTS rooms_company_a_player_fkey,
  DROP CONSTRAINT IF EXISTS rooms_company_d_player_fkey;

-- Make columns nullable and update type
ALTER TABLE rooms
  ALTER COLUMN company_a_player DROP NOT NULL,
  ALTER COLUMN company_d_player DROP NOT NULL;

-- Update column types
ALTER TABLE rooms
  ALTER COLUMN company_a_player TYPE uuid USING (company_a_player::uuid),
  ALTER COLUMN company_d_player TYPE uuid USING (company_d_player::uuid);

-- Add new foreign key constraints
ALTER TABLE rooms
  ADD CONSTRAINT rooms_company_a_player_fkey
    FOREIGN KEY (company_a_player)
    REFERENCES auth.users(id)
    ON DELETE SET NULL,
  ADD CONSTRAINT rooms_company_d_player_fkey
    FOREIGN KEY (company_d_player)
    REFERENCES auth.users(id)
    ON DELETE SET NULL;

-- Drop accounts table
DROP TABLE IF EXISTS accounts CASCADE;

-- Recreate all policies in correct order
CREATE POLICY "Users can read rooms they are in"
  ON rooms
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = company_a_player OR
    auth.uid() = company_d_player
  );

CREATE POLICY "Users can create rooms"
  ON rooms
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = company_a_player OR
    auth.uid() = company_d_player
  );

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

-- Recreate market share policies
CREATE POLICY "Users can read market share for their rooms"
  ON market_share
  FOR SELECT
  TO authenticated
  USING (
    room_id IN (
      SELECT id FROM rooms
      WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
    )
  );

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