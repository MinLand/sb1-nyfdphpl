-- Drop existing function if exists
DROP FUNCTION IF EXISTS record_player_action(text, text, integer, text, uuid, numeric, text);

-- Create function to safely record player actions with proper parameter handling
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

  -- Update market insights for relevant actions
  IF p_action_type IN ('conference', 'event') THEN
    PERFORM update_market_insights(
      p_room_id := p_room_id,
      p_round_number := p_round_number,
      p_hospital_id := (
        SELECT hospital_id 
        FROM doctors 
        WHERE id = p_target_id
      ),
      p_company_id := p_company_id,
      p_impact := CASE p_action_type
        WHEN 'conference' THEN CASE WHEN p_topic IS NOT NULL THEN 3 ELSE 1 END
        WHEN 'event' THEN 3
        ELSE 1
      END
    );
  END IF;

  RETURN v_action_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update market insights function to handle null values
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
  ON CONFLICT (room_id, round_number, hospital_id)
  DO UPDATE SET
    drug_a_adoption = CASE 
      WHEN EXCLUDED.drug_a_adoption > 0 THEN 
        LEAST(market_insights.drug_a_adoption + EXCLUDED.drug_a_adoption, 100)
      ELSE market_insights.drug_a_adoption
    END,
    drug_d_adoption = CASE 
      WHEN EXCLUDED.drug_d_adoption > 0 THEN 
        LEAST(market_insights.drug_d_adoption + EXCLUDED.drug_d_adoption, 100)
      ELSE market_insights.drug_d_adoption
    END,
    traditional_treatment_adoption = GREATEST(
      0,
      100 - LEAST(
        market_insights.drug_a_adoption + 
        CASE WHEN EXCLUDED.drug_a_adoption > 0 THEN EXCLUDED.drug_a_adoption ELSE 0 END +
        market_insights.drug_d_adoption + 
        CASE WHEN EXCLUDED.drug_d_adoption > 0 THEN EXCLUDED.drug_d_adoption ELSE 0 END,
        100
      )
    ),
    updated_at = now();
END;
$$ LANGUAGE plpgsql;