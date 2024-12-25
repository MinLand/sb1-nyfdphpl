/*
  # Fix market insights functionality

  1. Changes
    - Add missing room_id column to market_insights
    - Update unique constraint
    - Add proper indexes
    - Update RLS policies
*/

-- First drop existing constraints if they exist
ALTER TABLE market_insights 
DROP CONSTRAINT IF EXISTS market_insights_pkey,
DROP CONSTRAINT IF EXISTS market_insights_room_round_hospital_key;

-- Add room_id column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = 'market_insights' AND column_name = 'room_id'
  ) THEN
    ALTER TABLE market_insights ADD COLUMN room_id text REFERENCES rooms(id);
  END IF;
END $$;

-- Update existing records to have room_id from player_actions if needed
UPDATE market_insights mi
SET room_id = pa.room_id
FROM player_actions pa
WHERE mi.round_number = pa.round_number
AND mi.room_id IS NULL;

-- Make room_id NOT NULL after data migration
ALTER TABLE market_insights 
ALTER COLUMN room_id SET NOT NULL;

-- Recreate primary key and unique constraints
ALTER TABLE market_insights
ADD PRIMARY KEY (id),
ADD CONSTRAINT market_insights_unique_record 
  UNIQUE (room_id, round_number, hospital_id);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_market_insights_room_round
ON market_insights(room_id, round_number);

CREATE INDEX IF NOT EXISTS idx_market_insights_hospital
ON market_insights(hospital_id);

-- Drop existing policies
DROP POLICY IF EXISTS "Users can read market insights" ON market_insights;

-- Create new policies
CREATE POLICY "Users can read their room's market insights"
ON market_insights
FOR SELECT
TO authenticated
USING (
  room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  )
);

-- Update market insights function to handle room_id
CREATE OR REPLACE FUNCTION update_market_insights(
  p_room_id text,
  p_round_number integer,
  p_hospital_id uuid,
  p_company_id text,
  p_impact numeric
) RETURNS void AS $$
BEGIN
  INSERT INTO market_insights (
    room_id,
    round_number,
    hospital_id,
    total_patients,
    drug_a_adoption,
    drug_d_adoption,
    traditional_treatment_adoption
  )
  SELECT
    p_room_id,
    p_round_number,
    p_hospital_id,
    h.patient_count,
    CASE WHEN p_company_id = 'A' THEN p_impact ELSE 0 END,
    CASE WHEN p_company_id = 'D' THEN p_impact ELSE 0 END,
    100 - CASE WHEN p_company_id = 'A' THEN p_impact ELSE 0 END - 
         CASE WHEN p_company_id = 'D' THEN p_impact ELSE 0 END
  FROM hospitals h
  WHERE h.id = p_hospital_id
  ON CONFLICT ON CONSTRAINT market_insights_unique_record
  DO UPDATE SET
    drug_a_adoption = CASE 
      WHEN p_company_id = 'A' THEN 
        LEAST(market_insights.drug_a_adoption + p_impact, 100)
      ELSE market_insights.drug_a_adoption
    END,
    drug_d_adoption = CASE 
      WHEN p_company_id = 'D' THEN 
        LEAST(market_insights.drug_d_adoption + p_impact, 100)
      ELSE market_insights.drug_d_adoption
    END,
    traditional_treatment_adoption = GREATEST(
      0,
      100 - LEAST(
        market_insights.drug_a_adoption + 
        CASE WHEN p_company_id = 'A' THEN p_impact ELSE 0 END +
        market_insights.drug_d_adoption + 
        CASE WHEN p_company_id = 'D' THEN p_impact ELSE 0 END,
        100
      )
    ),
    updated_at = now();
END;
$$ LANGUAGE plpgsql;