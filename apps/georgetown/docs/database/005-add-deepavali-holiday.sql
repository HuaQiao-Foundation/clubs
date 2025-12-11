-- Add Deepavali 2025 holiday to events table
INSERT INTO events (date, type, title, description, created_by, updated_by)
VALUES ('2025-10-20', 'holiday', 'Deepavali', 'National holiday observed in Malaysia', 'system', 'system')
ON CONFLICT DO NOTHING;

-- Optional: Add other common Malaysian holidays if needed
-- Uncomment to add more holidays:

-- INSERT INTO events (date, type, title, description, created_by, updated_by) VALUES
--   ('2025-08-31', 'holiday', 'Merdeka Day', 'Malaysia Independence Day', 'system', 'system'),
--   ('2025-09-16', 'holiday', 'Malaysia Day', 'Formation of Malaysia', 'system', 'system'),
--   ('2025-12-25', 'holiday', 'Christmas Day', 'National holiday', 'system', 'system')
-- ON CONFLICT DO NOTHING;
