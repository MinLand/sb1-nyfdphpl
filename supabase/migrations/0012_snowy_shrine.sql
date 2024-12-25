/*
  # Fix conferences table constraints

  1. Changes
    - Drop existing role/topic constraint
    - Add new constraint that properly handles topic requirements
    - Add missing indexes for performance
  
  2. Security
    - Maintain existing RLS policies
*/

-- Drop existing constraint if it exists
ALTER TABLE conferences 
DROP CONSTRAINT IF EXISTS conferences_role_topic_check;

-- Add new constraint that properly handles topic requirements
ALTER TABLE conferences
ADD CONSTRAINT conferences_role_topic_check
CHECK (
  (role = 'speaker' AND topic IS NOT NULL) OR
  (role = 'attendee')
);

-- Add indexes for frequently queried columns
CREATE INDEX IF NOT EXISTS idx_conferences_room_doctor
ON conferences(room_id, doctor_id);

CREATE INDEX IF NOT EXISTS idx_conferences_week
ON conferences(week_number);