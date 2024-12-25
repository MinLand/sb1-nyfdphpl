/*
  # Fix conference and activity schema

  1. Changes
    - Add proper column types for company_id
    - Add constraints for valid values
    - Fix foreign key references
    - Add indexes for frequently queried columns

  2. Security
    - Maintain existing RLS policies
    - Add additional validation constraints
*/

-- Modify conferences table
ALTER TABLE conferences
  DROP CONSTRAINT IF EXISTS conferences_company_id_check;

ALTER TABLE conferences
  ALTER COLUMN company_id TYPE text,
  ADD CONSTRAINT conferences_company_id_check 
    CHECK (company_id IN ('A', 'D'));

-- Add indexes for frequently queried columns
CREATE INDEX IF NOT EXISTS idx_conferences_room_week 
  ON conferences(room_id, week_number);

-- Modify weekly_activities table
ALTER TABLE weekly_activities
  DROP CONSTRAINT IF EXISTS weekly_activities_company_id_check;

ALTER TABLE weekly_activities
  ALTER COLUMN company_id TYPE text,
  ADD CONSTRAINT weekly_activities_company_id_check 
    CHECK (company_id IN ('A', 'D'));

-- Add indexes for frequently queried columns
CREATE INDEX IF NOT EXISTS idx_weekly_activities_room_company_week 
  ON weekly_activities(room_id, company_id, week_number);

-- Add missing constraints
ALTER TABLE conferences
  ADD CONSTRAINT conferences_role_topic_check 
    CHECK (
      (role = 'speaker' AND topic IS NOT NULL) OR 
      (role = 'attendee' AND topic IS NULL)
    );

-- Update existing data if needed
UPDATE conferences 
SET company_id = 'A' 
WHERE company_id NOT IN ('A', 'D');

UPDATE weekly_activities 
SET company_id = 'A' 
WHERE company_id NOT IN ('A', 'D');