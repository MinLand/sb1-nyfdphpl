/*
  # Game Data Schema Update
  
  1. Changes
    - Drop existing tables to ensure clean state
    - Create hospitals table with proper schema
    - Create doctors table with knowledge scores
    - Create topics table for marketing content
    - Create market research data table
    
  2. Security
    - Enable RLS on all tables
    - Add read-only policies for authenticated users
*/

-- Drop existing tables if they exist
DROP TABLE IF EXISTS market_research_data CASCADE;
DROP TABLE IF EXISTS doctors CASCADE;
DROP TABLE IF EXISTS hospitals CASCADE;
DROP TABLE IF EXISTS topics CASCADE;

-- Create hospitals table
CREATE TABLE hospitals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  hospital_code text UNIQUE NOT NULL,
  patient_count integer NOT NULL
);

-- Create doctors table
CREATE TABLE doctors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  hospital_id uuid REFERENCES hospitals(id),
  title text NOT NULL,
  knowledge_scores jsonb NOT NULL DEFAULT '{}'::jsonb
);

-- Create topics table
CREATE TABLE topics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company text NOT NULL CHECK (company IN ('A', 'D')),
  title text NOT NULL,
  content text NOT NULL,
  characteristics text[] NOT NULL
);

-- Create market_research_data table
CREATE TABLE market_research_data (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id text REFERENCES rooms(id),
  hospital_id uuid REFERENCES hospitals(id),
  round_number integer NOT NULL,
  potential_patients integer NOT NULL,
  biological_usage_rate numeric NOT NULL,
  drug_a_share numeric NOT NULL,
  drug_d_share numeric NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(room_id, hospital_id, round_number)
);

-- Enable RLS
ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE market_research_data ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow read access to hospitals"
  ON hospitals FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow read access to doctors"
  ON doctors FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow read access to topics"
  ON topics FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can read their room's market research"
  ON market_research_data FOR SELECT
  TO authenticated
  USING (room_id IN (
    SELECT id FROM rooms
    WHERE company_a_player = auth.uid() OR company_d_player = auth.uid()
  ));

-- Insert initial data
INSERT INTO hospitals (hospital_code, name, patient_count) VALUES
  ('A', 'San Fan First Hospital', 750),
  ('B', 'Jiali Provincial People''s Hospital', 750),
  ('C', 'Yi Fan Center Hospital', 300),
  ('D', 'Er Fan Center Hospital', 300),
  ('E', 'Si Fan Center Hospital', 300),
  ('F', 'Wu Fan Center Hospital', 300);

-- Insert doctors
WITH hospital_ids AS (
  SELECT id, hospital_code FROM hospitals
)
INSERT INTO doctors (name, hospital_id, title, knowledge_scores) 
SELECT 
  d.name,
  h.id,
  d.title,
  d.scores::jsonb
FROM (
  VALUES 
    ('Dr. Zhao', 'A', 'Department Head', '{"aDrug": 90, "dDrug": 60, "hormones": 85, "immunosuppressants": 85}'),
    ('Dr. Qian', 'A', 'Associate Chief Physician', '{"aDrug": 75, "dDrug": 50, "hormones": 70, "immunosuppressants": 70}'),
    ('Dr. Sun', 'B', 'Department Head', '{"aDrug": 70, "dDrug": 65, "hormones": 80, "immunosuppressants": 80}'),
    ('Dr. Li', 'B', 'Associate Chief Physician', '{"aDrug": 65, "dDrug": 60, "hormones": 75, "immunosuppressants": 75}'),
    ('Dr. Zhou', 'B', 'Associate Chief Physician', '{"aDrug": 65, "dDrug": 60, "hormones": 75, "immunosuppressants": 75}'),
    ('Dr. Wu', 'C', 'Department Head', '{"aDrug": 60, "dDrug": 55, "hormones": 75, "immunosuppressants": 70}'),
    ('Dr. Zhen', 'D', 'Department Head', '{"aDrug": 65, "dDrug": 50, "hormones": 80, "immunosuppressants": 75}'),
    ('Dr. Wang', 'E', 'Department Head', '{"aDrug": 55, "dDrug": 50, "hormones": 70, "immunosuppressants": 65}'),
    ('Dr. Hong', 'F', 'Department Head', '{"aDrug": 60, "dDrug": 55, "hormones": 75, "immunosuppressants": 70}')
  ) d(name, hospital_code, title, scores)
JOIN hospital_ids h ON h.hospital_code = d.hospital_code;

-- Insert topics
INSERT INTO topics (company, title, content, characteristics) VALUES
  ('A', '兵贵神速——A药速度', 'a) 起效速度：A药>激素&免疫抑制剂>D药  b)尽早阻断可避免疾病进展', ARRAY['起效速度']),
  ('A', '新型白介素A药的疗效升级', 'a)8周应答率：A药>激素&免疫抑制剂', ARRAY['疗效']),
  ('A', '可长期持续使用的新型白介素A药', 'a) 相比于激素与免疫抑制剂指南不推荐使用超2年，A药拥有长期使用疗效数据(96周临床应答率60%)  b)即使出现长期使用应答率下降，仍可通过缩短间隔重新提升应答。', ARRAY['治疗持续性']),
  ('A', '新型白介素A药——PID安全之选', 'a) 相比于激素与免疫抑制剂可能增加恶心肿瘤与严重感染的风险，A药的仅仅小概率增加肿瘤与心血管风险。且可通过筛查等方式降低这些副反应事件。  b) 相比于激素与免疫抑制剂的使用存在较多禁忌(糖尿病、高血压、高血脂、围手术期人群需谨慎使用),A药不存在这些特殊人群的使用禁忌。', ARRAY['安全性']),
  ('D', '新型白介素D药的疗效升级', 'a) 8周应答率：D药>A药>激素&免疫抑制剂  b) 用于A药、激素&免疫抑制剂失应答的患者依然强效', ARRAY['疗效']),
  ('D', '论持久战——新型白介素D药的治疗持续性', 'a) 相比于激素与免疫抑制剂指南不推荐使用超2年，D药拥有长期使用疗效数据(96周临床应答率90%)  b) 相比于A药长期使用应答率下降，D药长期使用应答率维持高水平', ARRAY['治疗持续性']),
  ('D', '新型白介素D药——金字塔尖的安全性', 'a) 相比于激素与免疫抑制剂和A药可能增加肿瘤与心血管事件的风险，D药的副反应较为轻微，疲乏，恶心，头晕。  b) 相比于激素与免疫抑制剂的使用存在较多禁忌(糖尿病、高血压、高血脂、围手术期人群需谨慎使用),D药不存在这些特殊人群的使用禁忌。', ARRAY['安全性']),
  ('D', 'D药——生物制剂的便捷巅峰', 'a)相比于A药每月1次注射，只需每个季度1次注射', ARRAY['便捷性']);