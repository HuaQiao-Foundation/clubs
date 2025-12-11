-- Query to get all officers and committee chairs with their assigned members
-- This will help create a CSV export of roles and members

WITH expanded_roles AS (
    SELECT
        unnest(roles) as role,
        name
    FROM members
    WHERE roles && ARRAY[
        'President',
        'President-Elect',
        'Immediate Past President',
        'Vice President',
        'Secretary',
        'Treasurer',
        'Sergeant-at-Arms',
        'Club Administration Chair',
        'Club Membership Chair',
        'Club Public Image Chair',
        'Club Service Projects Chair',
        'Club Youth Service Chair',
        'Club International Service Chair',
        'Club Foundation Chair'
    ]
)
SELECT
    role,
    name
FROM expanded_roles
ORDER BY
    CASE role
        WHEN 'President' THEN 1
        WHEN 'President-Elect' THEN 2
        WHEN 'Immediate Past President' THEN 3
        WHEN 'Vice President' THEN 4
        WHEN 'Secretary' THEN 5
        WHEN 'Treasurer' THEN 6
        WHEN 'Sergeant-at-Arms' THEN 7
        WHEN 'Club Administration Chair' THEN 8
        WHEN 'Club Membership Chair' THEN 9
        WHEN 'Club Public Image Chair' THEN 10
        WHEN 'Club Service Projects Chair' THEN 11
        WHEN 'Club Youth Service Chair' THEN 12
        WHEN 'Club International Service Chair' THEN 13
        WHEN 'Club Foundation Chair' THEN 14
    END;
