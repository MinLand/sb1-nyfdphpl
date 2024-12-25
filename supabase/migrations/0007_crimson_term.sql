/*
  # Add Market Research Table

  1. New Tables
    - `market_research`
      - `id` (uuid, primary key)
      - `room_id` (text, references rooms)
      - `company_id` (text, A or D)
      - `week_number` (integer)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on `market_research` table
    - Add policies for authenticated users to read and create market research data
*/

-- Create market_research table
CREATE TABLE IF NOT EXISTS market_research (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id) NOT NULL,
  company_id text NOT NULL CHECK (company_id IN ('A', 'D')),
  week_number integer NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(room_id, company_id, week_number)
);

-- Enable RLS
ALTER TABLE market_research ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can read their room's market research"
  ON market_research
  FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

CREATE POLICY "Users can create market research in their room"
  ON market_research
  FOR INSERT
  TO authenticated
  WITH CHECK (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_market_research_room_company_week 
  ON market_research(room_id, company_id, week_number);