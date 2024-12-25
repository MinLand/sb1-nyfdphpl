/*
  # Database Integration and Optimization

  1. New Tables
    - `game_statistics` - Track game performance metrics
    - `player_actions` - Consolidated action tracking
    - `market_insights` - Aggregated market data

  2. Security
    - Enable RLS on all new tables
    - Add appropriate policies
    - Optimize indexes for performance

  3. Changes
    - Add foreign key constraints
    - Add performance indexes
    - Add audit timestamps
*/

-- Create game_statistics table
CREATE TABLE IF NOT EXISTS game_statistics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id),
  round_number integer NOT NULL,
  company_id text NOT NULL CHECK (company_id IN ('A', 'D')),
  market_share numeric NOT NULL DEFAULT 0,
  patient_reach integer NOT NULL DEFAULT 0,
  doctor_engagement_score numeric NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(room_id, round_number, company_id)
);

-- Create player_actions table
CREATE TABLE IF NOT EXISTS player_actions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id),
  round_number integer NOT NULL,
  company_id text NOT NULL CHECK (company_id IN ('A', 'D')),
  action_type text NOT NULL CHECK (
    action_type IN (
      'conference',
      'research',
      'visit',
      'event'
    )
  ),
  target_id uuid, -- References doctor or hospital
  impact_score numeric NOT NULL DEFAULT 0,
  cost numeric NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Create market_insights table
CREATE TABLE IF NOT EXISTS market_insights (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id),
  round_number integer NOT NULL,
  hospital_id uuid REFERENCES hospitals(id),
  total_patients integer NOT NULL DEFAULT 0,
  drug_a_adoption numeric NOT NULL DEFAULT 0,
  drug_d_adoption numeric NOT NULL DEFAULT 0,
  traditional_treatment_adoption numeric NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(room_id, round_number, hospital_id)
);

-- Enable RLS
ALTER TABLE game_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE market_insights ENABLE ROW LEVEL SECURITY;

-- Create policies for game_statistics
CREATE POLICY "Users can read their room's statistics"
  ON game_statistics
  FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

CREATE POLICY "Users can insert their room's statistics"
  ON game_statistics
  FOR INSERT
  TO authenticated
  WITH CHECK (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

-- Create policies for player_actions
CREATE POLICY "Users can read their room's actions"
  ON player_actions
  FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

CREATE POLICY "Users can insert their room's actions"
  ON player_actions
  FOR INSERT
  TO authenticated
  WITH CHECK (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

-- Create policies for market_insights
CREATE POLICY "Users can read their room's insights"
  ON market_insights
  FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

CREATE POLICY "Users can insert their room's insights"
  ON market_insights
  FOR INSERT
  TO authenticated
  WITH CHECK (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

-- Create indexes for performance
CREATE INDEX idx_game_statistics_lookup 
  ON game_statistics(room_id, round_number, company_id);

CREATE INDEX idx_player_actions_lookup 
  ON player_actions(room_id, round_number, company_id);

CREATE INDEX idx_market_insights_lookup 
  ON market_insights(room_id, round_number, hospital_id);

-- Create function to calculate market share
CREATE OR REPLACE FUNCTION calculate_market_share(
  p_room_id text,
  p_round_number integer,
  p_company_id text
) RETURNS numeric AS $$
DECLARE
  v_market_share numeric;
BEGIN
  SELECT 
    CASE p_company_id
      WHEN 'A' THEN AVG(drug_a_adoption)
      WHEN 'D' THEN AVG(drug_d_adoption)
    END
  INTO v_market_share
  FROM market_insights
  WHERE room_id = p_room_id 
    AND round_number = p_round_number;

  RETURN COALESCE(v_market_share, 0);
END;
$$ LANGUAGE plpgsql;