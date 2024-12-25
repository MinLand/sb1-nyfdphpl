/*
  # Game Schema Setup
  
  1. Tables
    - accounts: User authentication and profile data
    - rooms: Game room management
    - hospitals: Hospital information
    - doctors: Doctor profiles and knowledge scores
    - market_share: Market share tracking per hospital
  
  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Create tables if they don't exist
DO $$ 
BEGIN
    -- Accounts table
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'accounts') THEN
        CREATE TABLE accounts (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            username text UNIQUE NOT NULL,
            password_hash text NOT NULL,
            created_at timestamptz DEFAULT now()
        );
    END IF;

    -- Rooms table
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'rooms') THEN
        CREATE TABLE rooms (
            id text PRIMARY KEY,
            created_at timestamptz DEFAULT now(),
            status text NOT NULL DEFAULT 'waiting',
            company_a_player uuid REFERENCES accounts(id),
            company_d_player uuid REFERENCES accounts(id)
        );
    END IF;

    -- Hospitals table
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'hospitals') THEN
        CREATE TABLE hospitals (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            name text NOT NULL,
            patient_count integer NOT NULL DEFAULT 0
        );
    END IF;

    -- Doctors table
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'doctors') THEN
        CREATE TABLE doctors (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            name text NOT NULL,
            hospital_id uuid REFERENCES hospitals(id),
            a_drug_knowledge integer NOT NULL DEFAULT 0,
            d_drug_knowledge integer NOT NULL DEFAULT 0,
            hormone_knowledge integer NOT NULL DEFAULT 0,
            immunosuppressant_knowledge integer NOT NULL DEFAULT 0
        );
    END IF;

    -- Market share table
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'market_share') THEN
        CREATE TABLE market_share (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            hospital_id uuid REFERENCES hospitals(id),
            room_id text REFERENCES rooms(id),
            a_drug_share numeric NOT NULL DEFAULT 0,
            d_drug_share numeric NOT NULL DEFAULT 0,
            updated_at timestamptz DEFAULT now()
        );
    END IF;
END $$;

-- Enable Row Level Security
DO $$ 
BEGIN
    -- Enable RLS for each table
    EXECUTE 'ALTER TABLE accounts ENABLE ROW LEVEL SECURITY';
    EXECUTE 'ALTER TABLE rooms ENABLE ROW LEVEL SECURITY';
    EXECUTE 'ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY';
    EXECUTE 'ALTER TABLE doctors ENABLE ROW LEVEL SECURITY';
    EXECUTE 'ALTER TABLE market_share ENABLE ROW LEVEL SECURITY';
END $$;

-- Create or replace policies
DO $$ 
BEGIN
    -- Drop existing policies if they exist
    DROP POLICY IF EXISTS "Users can read their own account" ON accounts;
    DROP POLICY IF EXISTS "Users can read rooms they are in" ON rooms;
    DROP POLICY IF EXISTS "Users can read all hospitals" ON hospitals;
    DROP POLICY IF EXISTS "Users can read all doctors" ON doctors;
    DROP POLICY IF EXISTS "Users can read market share for their rooms" ON market_share;

    -- Create new policies
    CREATE POLICY "Users can read their own account"
        ON accounts
        FOR SELECT
        TO authenticated
        USING (auth.uid() = id);

    CREATE POLICY "Users can read rooms they are in"
        ON rooms
        FOR SELECT
        TO authenticated
        USING (
            auth.uid() = company_a_player OR
            auth.uid() = company_d_player
        );

    CREATE POLICY "Users can read all hospitals"
        ON hospitals
        FOR SELECT
        TO authenticated
        USING (true);

    CREATE POLICY "Users can read all doctors"
        ON doctors
        FOR SELECT
        TO authenticated
        USING (true);

    CREATE POLICY "Users can read market share for their rooms"
        ON market_share
        FOR SELECT
        TO authenticated
        USING (
            room_id IN (
                SELECT id FROM rooms
                WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
            )
        );
END $$;