/*
  # Fix database schema and constraints

  1. Changes
    - Fix doctor availability table structure
    - Update weekly activities constraints
    - Add proper indexes
    - Update increment_activity_count function

  2. Security
    - Maintain RLS policies
    - Ensure proper constraints
*/

-- Fix doctor_availability table
ALTER TABLE doctor_availability
DROP CONSTRAINT IF EXISTS doctor_availability_pkey CASCADE;

ALTER TABLE doctor_availability
  ADD COLUMN IF NOT EXISTS week_number integer,
  DROP COLUMN IF EXISTS round_number;

ALTER TABLE doctor_availability
  ADD PRIMARY KEY (id),
  ADD CONSTRAINT doctor_availability_unique_week 
    UNIQUE (room_id, doctor_id, week_number);

-- Update weekly_activities constraints
ALTER TABLE weekly_activities
DROP CONSTRAINT IF EXISTS weekly_activities_unique_activity;

ALTER TABLE weekly_activities
  ADD CONSTRAINT weekly_activities_unique_week
    UNIQUE (room_id, company_id, week_number);

-- Add performance indexes
CREATE INDEX IF NOT EXISTS idx_doctor_availability_lookup
  ON doctor_availability(room_id, doctor_id, week_number);

CREATE INDEX IF NOT EXISTS idx_weekly_activities_lookup
  ON weekly_activities(room_id, company_id, week_number);

-- Update increment_activity_count function
CREATE OR REPLACE FUNCTION increment_activity_count(
  p_room_id text,
  p_company_id text,
  p_week_number integer
) RETURNS void AS $$
BEGIN
  INSERT INTO weekly_activities (
    room_id, 
    company_id, 
    week_number, 
    activity_count
  )
  VALUES (
    p_room_id, 
    p_company_id, 
    p_week_number, 
    1
  )
  ON CONFLICT ON CONSTRAINT weekly_activities_unique_week
  DO UPDATE SET 
    activity_count = weekly_activities.activity_count + 1;
END;
$$ LANGUAGE plpgsql;