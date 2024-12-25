-- Drop existing policies if they exist
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Users can read their room's external events" ON external_events;
  DROP POLICY IF EXISTS "Users can create external events in their room" ON external_events;
EXCEPTION
  WHEN undefined_table THEN
    NULL;
END $$;

-- Create external_events table if it doesn't exist
CREATE TABLE IF NOT EXISTS external_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id),
  hospital_id text NOT NULL,
  doctor_id text NOT NULL,
  company_id text NOT NULL CHECK (company_id IN ('A', 'D')),
  event_type text NOT NULL CHECK (event_type IN ('academic', 'clinical', 'research')),
  topic text NOT NULL,
  week_number integer NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS if not already enabled
ALTER TABLE external_events ENABLE ROW LEVEL SECURITY;

-- Create new policies
CREATE POLICY "Users can read their room's external events"
  ON external_events
  FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

CREATE POLICY "Users can create external events in their room"
  ON external_events
  FOR INSERT
  TO authenticated
  WITH CHECK (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

-- Drop index if exists and create new one
DROP INDEX IF EXISTS idx_external_events_room_week;
CREATE INDEX idx_external_events_room_week 
  ON external_events(room_id, week_number);