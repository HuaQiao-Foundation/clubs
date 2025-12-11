-- Migration 017: Update Member Professional Classifications
-- Purpose: Update member classification field based on official Rotary club records
-- Date: 2025-10-10
-- CTO: Updates professional classifications for all members based on RC Georgetown membership data
-- Source: temp/RC Georgetown Membership Classifications.csv

-- Update classifications for all members (using exact names from database)
UPDATE members SET classification = 'Risk Management' WHERE name = 'Andrew Lay Keong Khoo';
UPDATE members SET classification = 'Law - General' WHERE name = 'Andrew Tatt Keong Lim';
UPDATE members SET classification = 'Engineering - Environment' WHERE name = 'Andy King';
UPDATE members SET classification = 'Event Management' WHERE name = 'Chin Tat Beh';
UPDATE members SET classification = 'Engineering - Electrical' WHERE name = 'Hong Pin Beh';
UPDATE members SET classification = 'Hospitality' WHERE name = 'Howard Roscoe';
UPDATE members SET classification = 'Interior Designer' WHERE name = 'Kelvan Seng Peng Lim';
UPDATE members SET classification = 'Corporate Secretarial Services' WHERE name = 'Peng-Loon Lee';
UPDATE members SET classification = 'Medical - Ophthalmology' WHERE name = 'Eng-Keong Lim';
UPDATE members SET classification = 'Tailoring Services' WHERE name = 'Maya Shewak Mahtani';
UPDATE members SET classification = 'Water Scientist' WHERE name = 'Michael Jackman';
UPDATE members SET classification = 'Architecture' WHERE name = 'Jin Cheng Ong';
UPDATE members SET classification = 'Business Intelligence Services' WHERE name = 'Randal Eric Eastman';
UPDATE members SET classification = 'Manufacturing - Environment' WHERE name = 'Yew-Aun Soh';
UPDATE members SET classification = 'Capital Investment' WHERE name = 'Walter Goon';
UPDATE members SET classification = 'Tax and Financial Consultant' WHERE name = 'Weeli Tan';
UPDATE members SET classification = 'Electrical Consultant' WHERE name = 'Wilson Lim';

-- Former Members
UPDATE members SET classification = 'Education' WHERE name = 'Richard Fuller';

-- Note: The following members are in the classification CSV but not in current member database:
-- James H Low (Contracting - Civil Works) - may have been removed or name changed
-- Caryn Lim (Business Development - Properties) - Former Member, may not be in current database

-- Note: Members with no classification in source data (remain NULL):
-- Jimmy See, Justin Anthony Culas, Pei Pei Lee, Synthia Surin

-- Verify the updates
SELECT name, classification, type
FROM members
ORDER BY name;
