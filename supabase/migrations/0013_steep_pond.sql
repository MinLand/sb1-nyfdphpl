/*
  # Fix conferences table constraint for attendees

  1. Changes
    - Drop existing role/topic constraint
    - Add new constraint that makes topic optional for attendees
    - Add missing indexes for performance optimization
  
  2. Security
    - Maintain existing RLS policies
*/

-- Drop existing constraint
ALTER TABLE conferences 
DROP CONSTRAINT IF EXISTS conferences_role_topic_check;

-- Add new constraint that makes topic optional for attendees
ALTER TABLE conferences
ADD CONSTRAINT conferences_role_topic_check
CHECK (
  (role = 'speaker' AND topic IS NOT NULL) OR
  (role = 'attendee' AND (topic IS NULL OR topic IS NOT NULL))
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_conferences_company_week
ON conferences(company_id, week_number);

CREATE INDEX IF NOT EXISTS idx_conferences_hospital_doctor
ON conferences(hospital_id, doctor_id);