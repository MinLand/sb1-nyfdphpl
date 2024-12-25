-- Modify player_actions table to use doctor_name
ALTER TABLE player_actions
ADD COLUMN doctor_name text,
DROP COLUMN target_id;

-- Create new function with updated parameters
CREATE OR REPLACE FUNCTION record_player_action(
  p_company_id text,
  p_round_number integer,
  p_action_type text,
  p_cost numeric,
  p_doctor_name text DEFAULT '0',
  p_topic text DEFAULT '0'
) RETURNS uuid AS $$
DECLARE
  v_action_id uuid;
BEGIN
  -- Validate parameters
  IF p_company_id IS NULL OR p_round_number IS NULL OR p_action_type IS NULL OR p_cost IS NULL THEN
    RAISE EXCEPTION 'Missing required parameters';
  END IF;

  -- Validate company_id
  IF p_company_id NOT IN ('A', 'D') THEN
    RAISE EXCEPTION 'Invalid company_id. Must be either A or D';
  END IF;

  -- Validate action_type
  IF p_action_type NOT IN ('conference', 'research', 'visit', 'event') THEN
    RAISE EXCEPTION 'Invalid action_type';
  END IF;

  -- Insert action with doctor_name
  INSERT INTO player_actions (
    company_id,
    round_number,
    action_type,
    doctor_name,
    cost,
    topic,
    impact_score
  ) VALUES (
    p_company_id,
    p_round_number,
    p_action_type,
    p_doctor_name,
    p_cost,
    p_topic,
    CASE p_action_type
      WHEN 'conference' THEN CASE WHEN p_topic != '0' THEN 3 ELSE 1 END
      WHEN 'event' THEN 3
      WHEN 'research' THEN 2
      ELSE 1
    END
  ) RETURNING id INTO v_action_id;

  -- Update market insights if needed
  IF p_action_type IN ('conference', 'event') AND p_doctor_name != '0' THEN
    PERFORM update_market_insights(
      p_company_id,
      p_round_number,
      (SELECT hospital_id FROM doctors WHERE name = p_doctor_name),
      CASE p_action_type
        WHEN 'conference' THEN CASE WHEN p_topic != '0' THEN 3 ELSE 1 END
        WHEN 'event' THEN 3
        ELSE 1
      END
    );
  END IF;

  RETURN v_action_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update market insights function to match new parameters
CREATE OR REPLACE FUNCTION update_market_insights(
  p_company_id text,
  p_round_number integer,
  p_hospital_id uuid,
  p_impact numeric
) RETURNS void AS $$
BEGIN
  INSERT INTO market_insights (
    round_number,
    hospital_id,
    total_patients,
    drug_a_adoption,
    drug_d_adoption,
    traditional_treatment_adoption
  )
  SELECT
    p_round_number,
    p_hospital_id,
    h.patient_count,
    CASE WHEN p_company_id = 'A' THEN p_impact ELSE 0 END,
    CASE WHEN p_company_id = 'D' THEN p_impact ELSE 0 END,
    100 - CASE WHEN p_company_id = 'A' THEN p_impact ELSE 0 END - 
         CASE WHEN p_company_id = 'D' THEN p_impact ELSE 0 END
  FROM hospitals h
  WHERE h.id = p_hospital_id
  ON CONFLICT (round_number, hospital_id)
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