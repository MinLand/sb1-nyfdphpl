-- Drop all existing versions of record_player_action function
DO $$ 
BEGIN
  -- Drop all versions of the function with different parameter lists
  DROP FUNCTION IF EXISTS record_player_action(text, text, integer, text, uuid, numeric, text);
  DROP FUNCTION IF EXISTS record_player_action(text, text, integer, text, text, numeric, text);
  DROP FUNCTION IF EXISTS record_player_action(text, text, integer, text, numeric, text, text);
  DROP FUNCTION IF EXISTS record_player_action(p_company_id text, p_round_number integer, p_action_type text, p_cost numeric, p_doctor_name text, p_topic text);
EXCEPTION 
  WHEN undefined_function THEN 
    NULL;
END $$;

-- Create the new version of the function
CREATE OR REPLACE FUNCTION record_player_action(
  p_company_id text,
  p_round_number integer,
  p_action_type text,
  p_cost numeric,
  p_doctor_name text DEFAULT '0',
  p_room_id integer,
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

  -- Insert action
  INSERT INTO player_actions (
    company_id,
    round_number,
    action_type,
    doctor_name,
    cost,
    topic,
    room_id,
    impact_score
  ) VALUES (
    p_company_id,
    p_round_number,
    p_action_type,
    p_doctor_name,
    p_cost,
    p_topic,
    p_room_id,
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