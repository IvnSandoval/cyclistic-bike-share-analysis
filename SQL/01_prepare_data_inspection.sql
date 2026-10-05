SELECT 
table_name,
ordinal_position,
column_name,
data_type
FROM information_schema.columns
WHERE table_schema = 'public'
	and table_name like 'divvy_trips_%'
ORDER BY table_name, ordinal_position;


-- 3. Check that each monthly table has 13 columns
SELECT
    table_name,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name LIKE 'divvy_trips_%'
GROUP BY table_name
ORDER BY table_name;


-- 4. Check whether column names and data types are consistent
-- across all 12 monthly tables
select
	ordinal_position,
	column_name,
	data_type,
	count(*) as tables_with_column
from information_schema."columns"
where table_schema = 'public'
	and table_name like 'divvy_trips_%'
group by
	ordinal_position,
	column_name,
	data_type
order by ordinal_position;

-- 5. check the number of rows in each dataset
SELECT '2025_09' AS month, COUNT(*) AS row_count FROM divvy_trips_2025_09
UNION ALL
SELECT '2025_10', COUNT(*) FROM divvy_trips_2025_10
UNION ALL
SELECT '2025_11', COUNT(*) FROM divvy_trips_2025_11
UNION ALL
SELECT '2025_12', COUNT(*) FROM divvy_trips_2025_12
UNION ALL
SELECT '2026_01', COUNT(*) FROM divvy_trips_2026_01
UNION ALL
SELECT '2026_02', COUNT(*) FROM divvy_trips_2026_02
UNION ALL
SELECT '2026_03', COUNT(*) FROM divvy_trips_2026_03
UNION ALL
SELECT '2026_04', COUNT(*) FROM divvy_trips_2026_04
UNION ALL
SELECT '2026_05', COUNT(*) FROM divvy_trips_2026_05
UNION ALL
SELECT '2026_06', COUNT(*) FROM divvy_trips_2026_06
UNION ALL
SELECT '2026_07', COUNT(*) FROM divvy_trips_2026_07
UNION ALL
SELECT '2026_08', COUNT(*) FROM divvy_trips_2026_08
ORDER BY month;