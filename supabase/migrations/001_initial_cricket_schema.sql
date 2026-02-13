-- STUMPED: Cricket match history schema (real scorecard-style)
-- Run this in Supabase SQL Editor after creating your project.

-- Matches: one row per match, with date and basic info
CREATE TABLE IF NOT EXISTS matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  played_at DATE NOT NULL,
  venue TEXT,
  batting_team_name TEXT NOT NULL,
  bowling_team_name TEXT NOT NULL,
  overs_limit INT NOT NULL,
  status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'abandoned', 'in_progress')),
  result_summary TEXT,
  notes TEXT
);

-- Innings: one or two per match (first innings, second innings)
CREATE TABLE IF NOT EXISTS innings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  innings_number INT NOT NULL CHECK (innings_number IN (1, 2)),
  batting_team_name TEXT NOT NULL,
  bowling_team_name TEXT NOT NULL,
  total_runs INT NOT NULL DEFAULT 0,
  total_wickets INT NOT NULL DEFAULT 0,
  total_balls INT NOT NULL DEFAULT 0,
  extras_wides INT NOT NULL DEFAULT 0,
  extras_no_balls INT NOT NULL DEFAULT 0,
  extras_byes INT NOT NULL DEFAULT 0,
  extras_leg_byes INT NOT NULL DEFAULT 0,
  extras_penalty INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_innings_match_id ON innings(match_id);

-- Batting scorecard: one row per batsman per innings (like real scorecard)
CREATE TABLE IF NOT EXISTS batting_scorecard (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  innings_id UUID NOT NULL REFERENCES innings(id) ON DELETE CASCADE,
  player_name TEXT NOT NULL,
  runs INT NOT NULL DEFAULT 0,
  balls_faced INT NOT NULL DEFAULT 0,
  fours INT NOT NULL DEFAULT 0,
  sixes INT NOT NULL DEFAULT 0,
  out_type TEXT,
  out_description TEXT,
  batting_position INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_batting_innings_id ON batting_scorecard(innings_id);

-- Bowling scorecard: one row per bowler per innings
CREATE TABLE IF NOT EXISTS bowling_scorecard (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  innings_id UUID NOT NULL REFERENCES innings(id) ON DELETE CASCADE,
  player_name TEXT NOT NULL,
  balls_bowled INT NOT NULL DEFAULT 0,
  maidens INT NOT NULL DEFAULT 0,
  runs_conceded INT NOT NULL DEFAULT 0,
  wickets INT NOT NULL DEFAULT 0,
  wides INT NOT NULL DEFAULT 0,
  no_balls INT NOT NULL DEFAULT 0,
  bowling_position INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_bowling_innings_id ON bowling_scorecard(innings_id);

-- RLS: allow anonymous read and insert for now (no auth required to start)
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE innings ENABLE ROW LEVEL SECURITY;
ALTER TABLE batting_scorecard ENABLE ROW LEVEL SECURITY;
ALTER TABLE bowling_scorecard ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anon read matches" ON matches FOR SELECT USING (true);
CREATE POLICY "Allow anon insert matches" ON matches FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anon read innings" ON innings FOR SELECT USING (true);
CREATE POLICY "Allow anon insert innings" ON innings FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anon read batting_scorecard" ON batting_scorecard FOR SELECT USING (true);
CREATE POLICY "Allow anon insert batting_scorecard" ON batting_scorecard FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anon read bowling_scorecard" ON bowling_scorecard FOR SELECT USING (true);
CREATE POLICY "Allow anon insert bowling_scorecard" ON bowling_scorecard FOR INSERT WITH CHECK (true);
