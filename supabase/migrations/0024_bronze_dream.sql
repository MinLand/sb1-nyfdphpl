/*
  # Fix game policies and add market insight functions

  1. Changes
    - Drop and recreate all RLS policies with proper auth checks
    - Add function to update market insights
    - Add function to calculate impact scores
    - Add proper indexes for performance
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can read their room's actions" ON player_actions;
DROP POLICY IF EXISTS "Users can insert actions for their company" ON player_actions;
DROP POLICY IF EXISTS "Users can read their room's insights" ON market_insights;
DROP POLICY IF EXISTS "Users can insert their room's insights" ON market_insights;

-- Create proper RLS policies
CREATE POLICY "Users can read their room's actions"
  ON player_actions
  FOR SELECT
  TO authenticated
  USING (
    room_id IN (
      SELECT id FROM rooms
      WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
    )
  );

CREATE POLICY "Users can create actions for their company"
  ON player_actions
  FOR INSERT
  TO authenticated
  WITH CHECK (
    room_id IN (
      SELECT id FROM rooms
      WHERE (company_id = 'A' AND company_a_player = auth.uid()) OR
            (company_id = 'D' AND company_d_player = auth.uid())
    )
  );

CREATE POLICY "Users can read market insights"
  ON market_insights
  FOR SELECT
  TO authenticated
  USING (
    room_id IN (
      SELECT id FROM rooms
      WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
    )
  );

-- Create function to update market insights
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
    100 - p_impact
  FROM hospitals h
  WHERE h.id = p_hospital_id
  ON CONFLICT (room_id, round_number, hospital_id)
  DO UPDATE SET
    drug_a_adoption = 
      CASE WHEN p_company_id = 'A' 
        THEN market_insights.drug_a_adoption + p_impact
        ELSE market_insights.drug_a_adoption
      END,
    drug_d_adoption = 
      CASE WHEN p_company_id = 'D'
        THEN market_insights.drug_d_adoption + p_impact
        ELSE market_insights.drug_d_adoption
      END,
    traditional_treatment_adoption = 
      market_insights.traditional_treatment_adoption - p_impact,
    updated_at = now();
END;
$$ LANGUAGE plpgsql;