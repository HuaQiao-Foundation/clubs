-- Create locations table for Georgetown Rotary location management
CREATE TABLE IF NOT EXISTS locations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  address TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add location_id foreign key to events table (assuming table is named 'events' or 'club_events')
-- Check your actual table name and adjust if needed
ALTER TABLE events ADD COLUMN IF NOT EXISTS location_id UUID REFERENCES locations(id) ON DELETE SET NULL;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_events_location_id ON events(location_id);

-- Enable Row Level Security
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

-- Create policies to allow all authenticated users full access
CREATE POLICY "Allow all users to read locations" ON locations
  FOR SELECT USING (true);

CREATE POLICY "Allow all users to insert locations" ON locations
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all users to update locations" ON locations
  FOR UPDATE USING (true);

CREATE POLICY "Allow all users to delete locations" ON locations
  FOR DELETE USING (true);

-- Create trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_locations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_locations_updated_at
  BEFORE UPDATE ON locations
  FOR EACH ROW
  EXECUTE FUNCTION update_locations_updated_at();

-- Enable Realtime for locations
ALTER PUBLICATION supabase_realtime ADD TABLE locations;

-- Insert some default Georgetown Rotary meeting locations
INSERT INTO locations (name, address, notes) VALUES
  ('St. Regis Hotel', 'Jalan Stesen Sentral 2, Kuala Lumpur Sentral', 'Regular club meeting venue'),
  ('Hilton KL', 'Jalan Stesen Sentral, Kuala Lumpur Sentral', 'Alternate meeting venue'),
  ('The Roof First Avenue', 'Jalan Bandar, Petaling Jaya', 'Special events venue'),
  ('Online (Zoom)', NULL, 'Virtual meetings')
ON CONFLICT (name) DO NOTHING;
