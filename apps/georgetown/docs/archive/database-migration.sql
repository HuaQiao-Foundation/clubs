-- Georgetown Rotary Speaker Management: Member Proposer Feature
-- Migration Script: Execute this in Supabase SQL Editor

-- 1. Create members table
CREATE TABLE IF NOT EXISTS members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prefix TEXT,
  name TEXT NOT NULL,
  gender TEXT,
  rotary_profile_url TEXT,
  role TEXT,
  type TEXT,
  member_since TEXT,
  email TEXT,
  mobile TEXT,
  phf TEXT,
  classification TEXT,
  linkedin TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- 2. Add proposer_id column to speakers table
ALTER TABLE speakers
ADD COLUMN IF NOT EXISTS proposer_id UUID REFERENCES members(id);

-- 3. Insert Georgetown Rotary Members
INSERT INTO members (prefix, name, gender, rotary_profile_url, role, type, member_since, email, mobile, phf, classification, linkedin, active) VALUES
('', 'Chin Tat Beh', 'Male', 'https://my.rotary.org/en/profile/5c3f703a-6f90-4c5f-bb24-aea12036b4f4', 'Member', 'Active', '2013', '', '+60 12 474 6282', '', '', '', true),
('', 'Hong Pin Beh', 'Male', 'https://my.rotary.org/en/profile/692d8bd7-73e7-401c-93a1-a6c51547b4f4', 'Member', 'Active', '2003', 'hpbehpg@gmail.com', '+60 12 401 2266', '', '', '', true),
('', 'Justin Anthony Culas', 'Male', 'https://my.rotary.org/en/profile/1865de7b-8c0a-436a-ae64-54b2c3c33deb', 'Member', 'Active', '2025', 'jc547499@gmail.com', '+60 12 470 1954', '', '', '', true),
('', 'Randal Eric Eastman', 'Male', 'https://my.rotary.org/en/profile/99ae4ff8-3605-4086-aefb-d2d0dc859df4', 'Member', 'Active', '2025', 'reastman@mac.com', '+60 16 3199439', 'PHF+2', 'Business Intelligence Services', 'https://www.linkedin.com/in/randaleastman/', true),
('', 'Walter Goon', 'Male', 'https://my.rotary.org/en/profile/416cc262-69ba-43af-a95b-1dcf2220b3f4', 'Club Foundation Chair', 'Active', '', 'goonwui@gmail.com', '+60 12 482 3730', '', '', '', true),
('', 'Michael Jackman', 'Male', 'https://my.rotary.org/en/profile/60d603a9-0199-484b-a91f-bbf1455632da', 'Club Membership Chair', 'Active', '', 'rmjackman@gmail.com', '+60 13 245 2401', '', '', '', true),
('', 'Andrew Lay Keong Khoo', 'Male', 'https://my.rotary.org/en/profile/d89b7923-9d57-4e72-b274-fe1ee43fb4f4', 'Club Secretary', 'Active', '', 'khoandrew@gmail.com', '+60 19 470 5857', '', '', '', true),
('', 'Andy King', 'Male', 'https://my.rotary.org/en/profile/79edf09c-b638-467c-abab-0a5b9377b3f4', 'Club Executive Secretary/Director', 'Active', '', 'andyk248@gmail.com', '+60 16 557 7242', '', '', '', true),
('', 'Pei Pei Lee', 'Female', 'https://my.rotary.org/en/profile/03ea9a04-101a-473e-91ee-782ae5103ceb', 'Member', 'Active', '2025', 'sylvia_lpp@hotmail.com', '+60 12 435 5498', '', '', '', true),
('', 'Peng-Loon Lee', 'Male', 'https://my.rotary.org/en/profile/fecb5345-b627-4ece-b312-e260484ab3f4', 'Member', 'Active', '1984', '', '', '', '', '', true),
('Datuk', 'Andrew Tatt Keong Lim', 'Male', 'https://my.rotary.org/en/profile/c85bd18a-f38a-47e2-b44d-efd29cb1b3f4', 'Club Treasurer', 'Active', '', 'andrewtklim@hotmail.com', '+60 12 931 7788', '', '', '', true),
('Dr.', 'Eng-Keong Lim', 'Male', 'https://my.rotary.org/en/profile/2b8fb1e3-2d0e-4805-afd6-d9ba85f9b3f4', 'Member', 'Active', '1983', '', '', '', '', '', true),
('', 'Kelvan Seng Peng Lim', 'Male', 'https://my.rotary.org/en/profile/300a9ab8-b861-4ad9-95cf-d44ede0cb4f4', 'Member', 'Active', '2018', '', '+60 13 431 4484', '', '', '', true),
('', 'Wilson Lim', 'Male', 'https://my.rotary.org/en/profile/93cd49ab-ce4f-42f2-9cec-7851dbe8b3f4', 'Club Service Projects Chair', 'Active', '', 'wilson.resonance@gmail.com', '+60 16 477 1850', '', '', '', true),
('', 'Maya Shewak Mahtani', 'Female', 'https://my.rotary.org/en/profile/d14ad144-8c4c-4569-ad90-0eedaed79eea', 'Member', 'Active', '2025', 'mayaa14@yahoo.co.uk', '+60 12 578 2552', '', '', '', true),
('', 'Jin Cheng Ong', 'Male', 'https://my.rotary.org/en/profile/86f39612-7e69-466a-988d-01ab3f1db4f4', 'Member', 'Active', '1988', '', '', '', '', '', true),
('', 'Howard Roscoe', 'Male', 'https://my.rotary.org/en/profile/b08086ec-dc65-41b8-95b3-61ea5ae0b3f4', 'Club President', 'Active', '', 'MyGweilo@gmail.com', '+60 12 205 6007', '', '', '', true),
('', 'Jimmy See', 'Male', 'https://my.rotary.org/en/profile/85870c57-1569-4e45-980b-8974cc77f9fa', 'Member', 'Active', '2025', '', '+60 16 223 5555', '', '', '', true),
('', 'Yew-Aun Soh', 'Male', 'https://my.rotary.org/en/profile/674f51ed-a306-45fa-b0d9-335b642ab4f4', 'Member', 'Active', '2000', 'sohyaun@gmail.com', '+60 12 489 7987', '', '', '', true),
('Dr.', 'Synthia Surin', 'Female', 'https://my.rotary.org/en/profile/136d7c86-bfc6-482e-a3b6-901b79ce3feb', 'Member', 'Active', '2025', 'synthiasurin@hotmail.com', '+60 17 477 7746', '', '', '', true),
('', 'Weeli Tan', 'Male', 'https://my.rotary.org/en/profile/b6e8fa4e-1a6a-4de8-8aab-7f3e228ea8f4', 'Vice President', 'Active', '2018', 'weeli.tan@gmail.com', '+60 12 230 1920', '', '', '', true);

-- 4. Enable RLS (Row Level Security) for members table
ALTER TABLE members ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS policy for members table (allow all operations for now)
CREATE POLICY "Enable all operations for members table" ON members
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

-- Migration complete!
-- Next steps:
-- 1. Update TypeScript types to include Member type and proposer_id field
-- 2. Modify UI components to include proposer selection and display
-- 3. Update API calls to fetch members data