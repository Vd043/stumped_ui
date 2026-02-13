-- Allow anonymous delete on matches (innings/scorecards cascade via FK).
CREATE POLICY "Allow anon delete matches" ON matches FOR DELETE USING (true);
