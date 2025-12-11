-- Create speakers table
CREATE TABLE IF NOT EXISTS speakers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  organization TEXT,
  topic TEXT NOT NULL,
  notes TEXT,
  status TEXT NOT NULL CHECK (status IN ('ideas', 'approached', 'agreed', 'scheduled', 'spoken', 'dropped')),
  scheduled_date DATE,
  position INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by TEXT NOT NULL,
  updated_by TEXT NOT NULL
);

-- Create index for faster queries
CREATE INDEX idx_speakers_status ON speakers(status);
CREATE INDEX idx_speakers_position ON speakers(position);

-- Enable Row Level Security
ALTER TABLE speakers ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all authenticated users to read
CREATE POLICY "Allow all users to read speakers" ON speakers
  FOR SELECT USING (true);

-- Create policy to allow all authenticated users to insert
CREATE POLICY "Allow all users to insert speakers" ON speakers
  FOR INSERT WITH CHECK (true);

-- Create policy to allow all authenticated users to update
CREATE POLICY "Allow all users to update speakers" ON speakers
  FOR UPDATE USING (true);

-- Create policy to allow all authenticated users to delete
CREATE POLICY "Allow all users to delete speakers" ON speakers
  FOR DELETE USING (true);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at
CREATE TRIGGER update_speakers_updated_at
  BEFORE UPDATE ON speakers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE speakers;