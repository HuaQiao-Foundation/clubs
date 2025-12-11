-- Create club_events table for Georgetown Rotary event management
CREATE TABLE IF NOT EXISTS club_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('club_meeting', 'club_event', 'service_project', 'holiday')),
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by TEXT NOT NULL,
  updated_by TEXT NOT NULL
);

-- Create indexes for faster queries
CREATE INDEX idx_club_events_date ON club_events(date);
CREATE INDEX idx_club_events_type ON club_events(type);

-- Enable Row Level Security
ALTER TABLE club_events ENABLE ROW LEVEL SECURITY;

-- Create policies to allow all authenticated users full access
CREATE POLICY "Allow all users to read club_events" ON club_events
  FOR SELECT USING (true);

CREATE POLICY "Allow all users to insert club_events" ON club_events
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all users to update club_events" ON club_events
  FOR UPDATE USING (true);

CREATE POLICY "Allow all users to delete club_events" ON club_events
  FOR DELETE USING (true);

-- Create trigger to auto-update updated_at
CREATE TRIGGER update_club_events_updated_at
  BEFORE UPDATE ON club_events
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Enable Realtime for club_events
ALTER PUBLICATION supabase_realtime ADD TABLE club_events;