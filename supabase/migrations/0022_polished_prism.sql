-- Add topic column to player_actions table
ALTER TABLE player_actions 
ADD COLUMN IF NOT EXISTS topic text;

-- Update indexes to include topic for better query performance
CREATE INDEX IF NOT EXISTS idx_player_actions_topic
ON player_actions(topic) WHERE topic IS NOT NULL;