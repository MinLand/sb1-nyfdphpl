-- Drop existing function
DROP FUNCTION IF EXISTS record_player_action;

-- Create updated function with modified parameters
CREATE OR REPLACE FUNCTION record_player_action(
  p_company_id text,
  p_round_number integer,
  p_action_type text,
  p_target_id text, -- Changed to text to store doctor name
  p_cost numeric,
  p_topic text DEFAULT '0' -- Default to '0' if no topic
) RETURNS uuid AS $$
DECLARE
  v_action_id uuid;
BEGIN
  -- Validate parameters
  IF p_company_id IS NULL OR p_round_number IS NULL OR p_action_type IS NULL THEN
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

  -- Insert action with modified parameters
  INSERT INTO player_actions (
    company_id,
    round_number,
    action_type,
    target_id, -- Now stores doctor name as text
    cost,
    topic,
    impact_score
  ) VALUES (
    p_company_id,
    p_round_number,
    p_action_type,
    COALESCE(p_target_id, '0'), -- Store '0' if no doctor
    p_cost,
    p_topic, -- Already has default '0'
    CASE p_action_type
      WHEN 'conference' THEN CASE WHEN p_topic != '0' THEN 3 ELSE 1 END
      WHEN 'event' THEN 3
      WHEN 'research' THEN 2
      ELSE 1
    END
  ) RETURNING id INTO v_action_id;

  RETURN v_action_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;