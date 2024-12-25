/*
  # Database Cleanup and Optimization

  1. Drop Unused Tables
    - Remove redundant and unused tables
    - Keep only essential game-related tables

  2. Security
    - Maintain RLS policies on remaining tables
    - Update foreign key relationships

  3. Changes
    - Clean up unused indexes
    - Remove deprecated functions
*/

-- Drop unused tables
DROP TABLE IF EXISTS market_share CASCADE;
DROP TABLE IF EXISTS weekly_activities CASCADE;
DROP TABLE IF EXISTS doctor_availability CASCADE;
DROP TABLE IF EXISTS conferences CASCADE;
DROP TABLE IF EXISTS external_events CASCADE;
DROP TABLE IF EXISTS market_research CASCADE;
DROP TABLE IF EXISTS market_research_data CASCADE;
DROP TABLE IF EXISTS doctor_characteristics CASCADE;

-- Drop unused functions
DROP FUNCTION IF EXISTS increment_activity_count(text, text, integer);

-- Keep essential tables:
-- - profiles (user profiles)
-- - rooms (game rooms)
-- - game_statistics (game performance)
-- - player_actions (player activities)
-- - market_insights (market data)
-- - hospitals (hospital information)
-- - doctors (doctor information)
-- - topics (academic topics)
-- - game_config (game settings)
-- - game_rounds (round management)

-- Update foreign key relationships
ALTER TABLE player_actions
DROP CONSTRAINT IF EXISTS player_actions_target_id_fkey,
ADD CONSTRAINT player_actions_target_id_fkey
  FOREIGN KEY (target_id)
  REFERENCES doctors(id)
  ON DELETE SET NULL;

-- Add missing indexes
CREATE INDEX IF NOT EXISTS idx_doctors_hospital
  ON doctors(hospital_id);

CREATE INDEX IF NOT EXISTS idx_topics_company
  ON topics(company);

-- Update game_rounds constraints
ALTER TABLE game_rounds
DROP CONSTRAINT IF EXISTS game_rounds_room_round_unique,
ADD CONSTRAINT game_rounds_room_round_unique
  UNIQUE (room_id, round_number);

-- Add updated_at columns where missing
ALTER TABLE game_statistics
ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

ALTER TABLE player_actions
ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

ALTER TABLE market_insights
ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for updated_at
DO $$ 
BEGIN
  CREATE TRIGGER update_game_statistics_updated_at
    BEFORE UPDATE ON game_statistics
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ 
BEGIN
  CREATE TRIGGER update_player_actions_updated_at
    BEFORE UPDATE ON player_actions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ 
BEGIN
  CREATE TRIGGER update_market_insights_updated_at
    BEFORE UPDATE ON market_insights
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;