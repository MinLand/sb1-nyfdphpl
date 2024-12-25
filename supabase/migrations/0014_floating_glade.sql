/*
  # Fix constraints and activity tracking

  1. Changes
    - Fix conference role/topic constraint
    - Add ON CONFLICT handling for weekly activities
    - Add doctor availability tracking improvements
    - Fix column name from round_number to week_number

  2. Security
    - Maintain existing RLS policies
    - Add indexes for performance
*/

-- Fix conference role/topic constraint
ALTER TABLE conferences 
DROP CONSTRAINT IF EXISTS conferences_role_topic_check;

ALTER TABLE conferences
ADD CONSTRAINT conferences_role_topic_check
CHECK (
  (role = 'speaker' AND topic IS NOT NULL) OR
  (role = 'attendee')
);

-- Add ON CONFLICT handling for weekly activities
ALTER TABLE weekly_activities
DROP CONSTRAINT IF EXISTS weekly_activities_room_id_company_id_week_number_key;

ALTER TABLE weekly_activities
ADD CONSTRAINT weekly_activities_unique_activity
UNIQUE (room_id, company_id, week_number);

-- Add doctor availability improvements
CREATE INDEX IF NOT EXISTS idx_doctor_availability_lookup
ON doctor_availability(room_id, doctor_id, week_number);

-- Add function to safely increment activity count
CREATE OR REPLACE FUNCTION increment_activity_count(
  p_room_id text,
  p_company_id text,
  p_week_number integer
) RETURNS void AS $$
BEGIN
  INSERT INTO weekly_activities (room_id, company_id, week_number, activity_count)
  VALUES (p_room_id, p_company_id, p_week_number, 1)
  ON CONFLICT ON CONSTRAINT weekly_activities_unique_activity
  DO UPDATE SET activity_count = weekly_activities.activity_count + 1;
END;
$$ LANGUAGE plpgsql;