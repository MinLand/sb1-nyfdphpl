/*
  # Conference Management Tables

  1. New Tables
    - `conferences`
      - Tracks conference sessions and their details
      - Includes hospital, doctor, role, and topic information
    - `weekly_activities`
      - Tracks weekly activity counts per company
      - Ensures compliance with weekly limits

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Create conferences table
CREATE TABLE IF NOT EXISTS conferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id),
  hospital_id text NOT NULL,
  doctor_id text NOT NULL,
  company_id text NOT NULL,
  role text NOT NULL CHECK (role IN ('speaker', 'attendee')),
  topic text,
  week_number integer NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create weekly_activities table
CREATE TABLE IF NOT EXISTS weekly_activities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id),
  company_id text NOT NULL,
  week_number integer NOT NULL,
  activity_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(room_id, company_id, week_number)
);

-- Enable RLS
ALTER TABLE conferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_activities ENABLE ROW LEVEL SECURITY;

-- Policies for conferences
CREATE POLICY "Users can read their room's conferences"
  ON conferences
  FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

CREATE POLICY "Users can create conferences in their room"
  ON conferences
  FOR INSERT
  TO authenticated
  WITH CHECK (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

-- Policies for weekly_activities
CREATE POLICY "Users can read their room's activities"
  ON weekly_activities
  FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

CREATE POLICY "Users can update their room's activities"
  ON weekly_activities
  FOR ALL
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ))
  WITH CHECK (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));