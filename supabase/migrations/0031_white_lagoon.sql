/*
  # Fix record_player_action function

  1. Changes
    - Drop all existing versions of the function
    - Create single version with correct parameters
    - Add proper validation
    - Fix room_id parameter type
  
  2. Security
    - Maintain SECURITY DEFINER
    - Add parameter validation
*/

-- Drop all existing versions of record_player_action function
DO $$ 
BEGIN
  -- Drop all versions of the function with different parameter lists
  DROP FUNCTION IF EXISTS record_player_action(text, text, integer, text, uuid, numeric, text);
  DROP FUNCTION IF EXISTS record_player_action(text, text, integer, text, text, numeric, text);
  DROP FUNCTION IF EXISTS record_player_action(text, text, integer, text, numeric, text, text);
  DROP FUNCTION IF EXISTS record_player_action(text, integer, text, numeric, text, integer, text);
  DROP FUNCTION IF EXISTS record_player_action(text, integer, text, numeric, text, text);
EXCEPTION 
  WHEN undefined_function THEN 
    NULL;
END $$;

-- Create new version with correct parameters
CREATE OR REPLACE FUNCTION record_player_action(
  p_action_type text,
  p_company_id text,
  p_cost numeric,
  p_doctor_name text,
  p_room_id text,
  p_round_number integer,
  p_topic text DEFAULT NULL
) RETURNS uuid AS $$
DECLARE
  v_action_id uuid;
BEGIN
  -- Validate required parameters
  IF p_room_id IS NULL OR p_company_id IS NULL OR p_round_number IS NULL OR p_action_type IS NULL OR p_cost IS NULL THEN
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
    doctor_name,
    cost,
    topic,
    impact_score
  ) VALUES (
    p_room_id,
    p_company_id,
    p_round_number,
    p_action_type,
    COALESCE(p_doctor_name, '0'),
    p_cost,
    COALESCE(p_topic, '0'),
    CASE p_action_type
      WHEN 'conference' THEN CASE WHEN p_topic IS NOT NULL THEN 3 ELSE 1 END
      WHEN 'event' THEN 3
      WHEN 'research' THEN 2
      ELSE 1
    END
  ) RETURNING id INTO v_action_id;

  RETURN v_action_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;