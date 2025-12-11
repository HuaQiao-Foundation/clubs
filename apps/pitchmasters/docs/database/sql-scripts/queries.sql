-- ============================================================
-- Reusable Queries for Pitchmasters
-- Purpose: Common analytics and operational queries
-- Last Updated: 2025-10-08
-- ============================================================
-- Usage: Replace placeholders {club_id}, {user_id}, {meeting_id} with actual UUIDs

-- ============================================================
-- MEMBER QUERIES
-- ============================================================

-- Query: Get all active members for a club
-- Usage: Replace {club_id} with actual UUID
SELECT
    u.id,
    u.full_name,
    u.email,
    u.role,
    mp.path_level,
    mp.current_path,
    mp.venture_name
FROM users u
LEFT JOIN member_profiles mp ON u.id = mp.user_id
WHERE u.club_id = '{club_id}'
ORDER BY u.full_name;

-- Query: Get member profile with privacy settings
-- Usage: Replace {user_id} with actual UUID
SELECT
    u.full_name,
    u.email,
    mp.*,
    ps.show_photo,
    ps.show_venture_info,
    ps.show_linkedin
FROM users u
JOIN member_profiles mp ON u.id = mp.user_id
LEFT JOIN privacy_settings ps ON u.id = ps.user_id
WHERE u.id = '{user_id}';

-- Query: Search members by expertise or industry
-- Usage: Replace {club_id} and {search_term}
SELECT
    u.full_name,
    mp.venture_name,
    mp.industry,
    mp.expertise_areas,
    mp.path_level
FROM users u
JOIN member_profiles mp ON u.id = mp.user_id
WHERE u.club_id = '{club_id}'
    AND (
        mp.industry ILIKE '%{search_term}%'
        OR '{search_term}' = ANY(mp.expertise_areas)
    )
ORDER BY u.full_name;

-- Query: Get club founders (for recognition)
-- Usage: Replace {club_id}
SELECT
    u.full_name,
    mp.joining_date,
    mp.venture_name,
    mp.path_level
FROM users u
JOIN member_profiles mp ON u.id = mp.user_id
WHERE u.club_id = '{club_id}'
    AND mp.is_founder = true
ORDER BY mp.joining_date;

-- Query: Birthday report for current month
-- Usage: Replace {club_id} and {month_name} (e.g., 'January')
SELECT
    u.full_name,
    mp.birthday_month,
    mp.birthday_day,
    mp.venture_name
FROM users u
JOIN member_profiles mp ON u.id = mp.user_id
WHERE u.club_id = '{club_id}'
    AND mp.birthday_month = '{month_name}'
ORDER BY mp.birthday_day;

-- ============================================================
-- MEETING QUERIES
-- ============================================================

-- Query: Upcoming meetings for a club
-- Usage: Replace {club_id}
SELECT
    m.id,
    m.title,
    m.date,
    m.start_time,
    m.end_time,
    m.meeting_type,
    m.status
FROM meetings m
WHERE m.club_id = '{club_id}'
    AND m.date >= CURRENT_DATE
    AND m.status != 'cancelled'
ORDER BY m.date, m.start_time;

-- Query: Meeting details with all roles
-- Usage: Replace {meeting_id}
SELECT
    m.title,
    m.date,
    m.start_time,
    mr.role_type,
    u.full_name as assigned_to
FROM meetings m
LEFT JOIN meeting_roles mr ON m.id = mr.meeting_id
LEFT JOIN users u ON mr.user_id = u.id
WHERE m.id = '{meeting_id}'
ORDER BY mr.role_type;

-- Query: Meetings with speech count
-- Usage: Replace {club_id}
SELECT
    m.title,
    m.date,
    m.meeting_type,
    COUNT(s.id) as speech_count
FROM meetings m
LEFT JOIN speeches s ON m.id = s.meeting_id
WHERE m.club_id = '{club_id}'
    AND m.status = 'completed'
GROUP BY m.id, m.title, m.date, m.meeting_type
ORDER BY m.date DESC
LIMIT 10;

-- Query: Unfilled meeting roles (for reminders)
-- Usage: Replace {meeting_id}
SELECT
    m.title,
    m.date,
    mr.role_type
FROM meetings m
JOIN meeting_roles mr ON m.id = mr.meeting_id
WHERE m.id = '{meeting_id}'
    AND mr.user_id IS NULL
ORDER BY mr.role_type;

-- ============================================================
-- SPEECH QUERIES
-- ============================================================

-- Query: Member speech history
-- Usage: Replace {user_id}
SELECT
    s.title,
    s.manual,
    s.project_number,
    s.duration_minutes,
    m.date,
    m.title as meeting_title
FROM speeches s
JOIN meetings m ON s.meeting_id = m.id
WHERE s.user_id = '{user_id}'
ORDER BY m.date DESC;

-- Query: Speech count by member (leaderboard)
-- Usage: Replace {club_id}
SELECT
    u.full_name,
    COUNT(s.id) as total_speeches,
    mp.path_level,
    mp.current_path
FROM users u
LEFT JOIN speeches s ON u.id = s.user_id
LEFT JOIN member_profiles mp ON u.id = mp.user_id
WHERE u.club_id = '{club_id}'
GROUP BY u.id, u.full_name, mp.path_level, mp.current_path
ORDER BY total_speeches DESC, u.full_name;

-- Query: Pathways progress by path
-- Usage: Replace {club_id}
SELECT
    mp.current_path,
    mp.path_level,
    COUNT(*) as member_count
FROM member_profiles mp
JOIN users u ON mp.user_id = u.id
WHERE u.club_id = '{club_id}'
GROUP BY mp.current_path, mp.path_level
ORDER BY mp.current_path, mp.path_level;

-- Query: Recent speeches across club
-- Usage: Replace {club_id}
SELECT
    u.full_name as speaker,
    s.title as speech_title,
    s.manual,
    s.project_number,
    m.date,
    m.title as meeting_title
FROM speeches s
JOIN users u ON s.user_id = u.id
JOIN meetings m ON s.meeting_id = m.id
WHERE m.club_id = '{club_id}'
    AND m.status = 'completed'
ORDER BY m.date DESC
LIMIT 20;

-- ============================================================
-- ANALYTICS QUERIES
-- ============================================================

-- Query: Club activity summary
-- Usage: Replace {club_id}
SELECT
    c.name as club_name,
    COUNT(DISTINCT u.id) as total_members,
    COUNT(DISTINCT CASE WHEN u.role IN ('officer', 'admin') THEN u.id END) as officers_count,
    COUNT(DISTINCT m.id) as total_meetings,
    COUNT(DISTINCT s.id) as total_speeches,
    COUNT(DISTINCT CASE WHEN m.date >= CURRENT_DATE - INTERVAL '30 days' THEN m.id END) as meetings_last_30_days
FROM clubs c
LEFT JOIN users u ON c.id = u.club_id
LEFT JOIN meetings m ON c.id = m.club_id
LEFT JOIN speeches s ON m.id = s.meeting_id
WHERE c.id = '{club_id}'
GROUP BY c.id, c.name;

-- Query: Member engagement metrics
-- Usage: Replace {club_id}
SELECT
    u.full_name,
    COUNT(DISTINCT s.id) as speeches_delivered,
    COUNT(DISTINCT mr.id) as roles_filled,
    MAX(m.date) as last_participation_date,
    mp.venture_name
FROM users u
LEFT JOIN speeches s ON u.id = s.user_id
LEFT JOIN meeting_roles mr ON u.id = mr.user_id
LEFT JOIN meetings m ON (s.meeting_id = m.id OR mr.meeting_id = m.id)
LEFT JOIN member_profiles mp ON u.id = mp.user_id
WHERE u.club_id = '{club_id}'
GROUP BY u.id, u.full_name, mp.venture_name
ORDER BY speeches_delivered DESC, roles_filled DESC;

-- Query: Monthly meeting attendance trend
-- Usage: Replace {club_id}
SELECT
    DATE_TRUNC('month', m.date) as month,
    COUNT(m.id) as meetings_held,
    COUNT(s.id) as total_speeches,
    COUNT(DISTINCT s.user_id) as unique_speakers
FROM meetings m
LEFT JOIN speeches s ON m.id = s.meeting_id
WHERE m.club_id = '{club_id}'
    AND m.status = 'completed'
    AND m.date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', m.date)
ORDER BY month DESC;

-- Query: Role distribution across members
-- Usage: Replace {club_id}
SELECT
    u.full_name,
    COUNT(DISTINCT mr.role_type) as unique_roles_filled,
    STRING_AGG(DISTINCT mr.role_type, ', ') as roles
FROM users u
JOIN meeting_roles mr ON u.id = mr.user_id
JOIN meetings m ON mr.meeting_id = m.id
WHERE m.club_id = '{club_id}'
    AND m.status = 'completed'
GROUP BY u.id, u.full_name
ORDER BY unique_roles_filled DESC;

-- ============================================================
-- ADMINISTRATIVE QUERIES
-- ============================================================

-- Query: Officers and their roles
-- Usage: Replace {club_id}
SELECT
    u.full_name,
    u.email,
    u.role as system_role,
    mp.officer_role,
    mp.team
FROM users u
LEFT JOIN member_profiles mp ON u.id = mp.user_id
WHERE u.club_id = '{club_id}'
    AND u.role IN ('officer', 'admin')
ORDER BY u.role DESC, u.full_name;

-- Query: Members without profiles (for data completion)
-- Usage: Replace {club_id}
SELECT
    u.id,
    u.full_name,
    u.email,
    u.created_at
FROM users u
LEFT JOIN member_profiles mp ON u.id = mp.user_id
WHERE u.club_id = '{club_id}'
    AND mp.id IS NULL
ORDER BY u.created_at DESC;

-- Query: Privacy settings audit
-- Usage: Replace {club_id}
SELECT
    u.full_name,
    CASE WHEN ps.show_photo THEN 'Yes' ELSE 'No' END as shows_photo,
    CASE WHEN ps.show_venture_info THEN 'Yes' ELSE 'No' END as shows_venture,
    CASE WHEN ps.show_linkedin THEN 'Yes' ELSE 'No' END as shows_linkedin,
    CASE WHEN ps.allow_cross_club_visibility THEN 'Yes' ELSE 'No' END as cross_club
FROM users u
LEFT JOIN privacy_settings ps ON u.id = ps.user_id
WHERE u.club_id = '{club_id}'
ORDER BY u.full_name;

-- ============================================================
-- DATA CLEANUP QUERIES
-- ============================================================

-- Query: Find duplicate emails across clubs
SELECT
    email,
    COUNT(*) as club_count,
    STRING_AGG(c.name, ', ') as clubs
FROM users u
JOIN clubs c ON u.club_id = c.id
GROUP BY email
HAVING COUNT(*) > 1;

-- Query: Orphaned privacy settings (no matching profile)
SELECT ps.*
FROM privacy_settings ps
LEFT JOIN member_profiles mp ON ps.user_id = mp.user_id
WHERE mp.id IS NULL;

-- Query: Meetings without any roles assigned
-- Usage: Replace {club_id}
SELECT
    m.title,
    m.date,
    m.status
FROM meetings m
LEFT JOIN meeting_roles mr ON m.id = mr.meeting_id
WHERE m.club_id = '{club_id}'
    AND mr.id IS NULL
    AND m.status = 'scheduled'
ORDER BY m.date;

-- ============================================================
-- REPORTING QUERIES
-- ============================================================

-- Query: Club demographics summary
-- Usage: Replace {club_id}
SELECT
    COUNT(DISTINCT u.id) as total_members,
    COUNT(DISTINCT CASE WHEN mp.is_founder THEN u.id END) as founders,
    COUNT(DISTINCT CASE WHEN mp.is_rotarian THEN u.id END) as rotarians,
    COUNT(DISTINCT mp.industry) as unique_industries,
    COUNT(DISTINCT CASE WHEN mp.member_type = 'New' THEN u.id END) as new_members,
    AVG(mp.speech_count) as avg_speeches_per_member
FROM users u
LEFT JOIN member_profiles mp ON u.id = mp.user_id
WHERE u.club_id = '{club_id}';

-- Query: Venture stage distribution
-- Usage: Replace {club_id}
SELECT
    mp.venture_stage,
    COUNT(*) as member_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as percentage
FROM member_profiles mp
JOIN users u ON mp.user_id = u.id
WHERE u.club_id = '{club_id}'
    AND mp.venture_stage IS NOT NULL
GROUP BY mp.venture_stage
ORDER BY member_count DESC;

-- ============================================================
-- End of Queries
-- ============================================================
