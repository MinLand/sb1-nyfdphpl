/*
  # Initialize Game Data
  
  1. Updates
    - Add hospital PID patient counts
    - Add doctor knowledge scores and characteristics
    - Add initial market research data
*/

-- Update hospitals with PID patient counts
UPDATE hospitals 
SET patient_count = CASE hospital_code
  WHEN 'A' THEN 750
  WHEN 'B' THEN 750
  WHEN 'C' THEN 300
  WHEN 'D' THEN 300
  WHEN 'E' THEN 300
  WHEN 'F' THEN 300
  ELSE patient_count
END;

-- Update doctors knowledge scores
UPDATE doctors
SET knowledge_scores = CASE name
  WHEN 'Dr. Zhao' THEN '{"aDrug": 380, "dDrug": 10, "hormones": 150, "immunosuppressants": 150}'::jsonb
  WHEN 'Dr. Qian' THEN '{"aDrug": 380, "dDrug": 10, "hormones": 150, "immunosuppressants": 150}'::jsonb
  WHEN 'Dr. Sun' THEN '{"aDrug": 30, "dDrug": 5, "hormones": 90, "immunosuppressants": 90}'::jsonb
  WHEN 'Dr. Li' THEN '{"aDrug": 30, "dDrug": 5, "hormones": 100, "immunosuppressants": 100}'::jsonb
  WHEN 'Dr. Zhou' THEN '{"aDrug": 30, "dDrug": 5, "hormones": 100, "immunosuppressants": 100}'::jsonb
  WHEN 'Dr. Wu' THEN '{"aDrug": 15, "dDrug": 0, "hormones": 60, "immunosuppressants": 60}'::jsonb
  WHEN 'Dr. Zhen' THEN '{"aDrug": 15, "dDrug": 0, "hormones": 60, "immunosuppressants": 60}'::jsonb
  WHEN 'Dr. Wang' THEN '{"aDrug": 15, "dDrug": 0, "hormones": 60, "immunosuppressants": 60}'::jsonb
  WHEN 'Dr. Hong' THEN '{"aDrug": 15, "dDrug": 0, "hormones": 60, "immunosuppressants": 60}'::jsonb
  ELSE knowledge_scores
END;

-- Create doctor_characteristics table if not exists
CREATE TABLE IF NOT EXISTS doctor_characteristics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id uuid REFERENCES doctors(id),
  onset_speed integer DEFAULT 0,
  efficacy integer DEFAULT 0,
  treatment_duration integer DEFAULT 0,
  safety integer DEFAULT 0,
  convenience integer DEFAULT 0,
  economics integer DEFAULT 0,
  discipline_development integer DEFAULT 0,
  disease_field integer DEFAULT 0,
  treatment_plan integer DEFAULT 0,
  mdt_communication integer DEFAULT 0,
  research_related integer DEFAULT 0,
  decision_weight numeric DEFAULT 0,
  UNIQUE(doctor_id)
);

-- Enable RLS
ALTER TABLE doctor_characteristics ENABLE ROW LEVEL SECURITY;

-- Create policy
CREATE POLICY "Allow read access to doctor characteristics"
  ON doctor_characteristics FOR SELECT
  TO authenticated
  USING (true);

-- Insert doctor characteristics
INSERT INTO doctor_characteristics (
  doctor_id,
  onset_speed,
  efficacy,
  treatment_duration,
  safety,
  convenience,
  economics,
  discipline_development,
  disease_field,
  treatment_plan,
  mdt_communication,
  research_related,
  decision_weight
)
SELECT 
  d.id,
  CASE 
    WHEN d.name = 'Dr. Zhao' THEN 1
    WHEN d.name = 'Dr. Qian' THEN 1
    WHEN d.name = 'Dr. Sun' THEN 0
    WHEN d.name = 'Dr. Li' THEN 0
    WHEN d.name = 'Dr. Zhou' THEN 0
    ELSE 1
  END as onset_speed,
  1 as efficacy,
  CASE 
    WHEN d.name IN ('Dr. Sun', 'Dr. Li', 'Dr. Zhou') THEN 1
    ELSE 0
  END as treatment_duration,
  CASE 
    WHEN d.name = 'Dr. Zhao' THEN 0
    WHEN d.name = 'Dr. Qian' THEN 1
    ELSE 1
  END as safety,
  CASE 
    WHEN d.name IN ('Dr. Zhao', 'Dr. Qian') THEN 1
    ELSE 0
  END as convenience,
  CASE 
    WHEN d.name IN ('Dr. Wu', 'Dr. Zhen', 'Dr. Wang', 'Dr. Hong') THEN 1
    ELSE 0
  END as economics,
  CASE 
    WHEN d.name IN ('Dr. Sun', 'Dr. Li') THEN 1
    ELSE 0
  END as discipline_development,
  CASE 
    WHEN d.name = 'Dr. Zhao' THEN 2
    WHEN d.name IN ('Dr. Li', 'Dr. Zhou') THEN 2
    ELSE 0
  END as disease_field,
  1 as treatment_plan,
  CASE 
    WHEN d.name IN ('Dr. Zhao', 'Dr. Sun') THEN 2
    ELSE 0
  END as mdt_communication,
  CASE 
    WHEN d.name IN ('Dr. Zhao', 'Dr. Qian', 'Dr. Li', 'Dr. Zhou') THEN 2
    ELSE 0
  END as research_related,
  CASE
    WHEN d.name = 'Dr. Zhao' THEN 0.9
    WHEN d.name = 'Dr. Qian' THEN 0.1
    WHEN d.name = 'Dr. Sun' THEN 0.5
    WHEN d.name = 'Dr. Li' THEN 0.25
    WHEN d.name = 'Dr. Zhou' THEN 0.25
    ELSE 1.0
  END as decision_weight
FROM doctors d
ON CONFLICT (doctor_id) DO UPDATE
SET
  onset_speed = EXCLUDED.onset_speed,
  efficacy = EXCLUDED.efficacy,
  treatment_duration = EXCLUDED.treatment_duration,
  safety = EXCLUDED.safety,
  convenience = EXCLUDED.convenience,
  economics = EXCLUDED.economics,
  discipline_development = EXCLUDED.discipline_development,
  disease_field = EXCLUDED.disease_field,
  treatment_plan = EXCLUDED.treatment_plan,
  mdt_communication = EXCLUDED.mdt_communication,
  research_related = EXCLUDED.research_related,
  decision_weight = EXCLUDED.decision_weight;