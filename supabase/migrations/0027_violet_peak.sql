-- Drop existing function if exists
DROP FUNCTION IF EXISTS record_player_action;

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
  -- Validate parameters
  IF p_room_id IS NULL OR p_company_id IS NULL OR p_round_number IS NULL OR p_action_type IS NULL THEN
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

  -- Update market insights if needed
  IF p_action_type IN ('conference', 'event') AND p_target_id IS NOT NULL THEN
    PERFORM update_market_insights(
      p_room_id,
      p_round_number,
      (SELECT hospital_id FROM doctors WHERE id = p_target_id),
      p_company_id,
      CASE p_action_type
        WHEN 'conference' THEN CASE WHEN p_topic IS NOT NULL THEN 3 ELSE 1 END
        WHEN 'event' THEN 3
        ELSE 1
      END
    );
  END IF;

  RETURN v_action_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;