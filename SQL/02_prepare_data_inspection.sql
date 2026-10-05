-- 1. sample of table: look specifically at satrted_at column
SELECT *
FROM divvy_trips_2025_09
ORDER BY started_at
LIMIT 100;


-- 2. shows latest riders first
SELECT *
FROM divvy_trips_2025_09
ORDER BY started_at DESC
LIMIT 100;

-- 3. confirm that the range is within september 2025
--there are some august riders in the september table
SELECT
    MIN(started_at) AS earliest_ride,
    MAX(started_at) AS latest_ride
FROM divvy_trips_2025_12;

SELECT COUNT(*) AS august_rides_in_september_file
FROM divvy_trips_2025_09
WHERE started_at < '2025-09-01';

-- 4. find out how many august riders in september table
--there are 268
SELECT COUNT(*) AS august_rides_in_september_file
FROM divvy_trips_2025_09
WHERE started_at < '2025-09-01';

-- 5. look at the august records
--the start_at begins in august, but the end_at ends in spetember
SELECT *
FROM divvy_trips_2025_09
WHERE started_at < '2025-09-01'
ORDER BY started_at;

-- 6. check the member vs casual
--September 2025 table: member(449,298) and casual(265,461)
SELECT
    member_casual,
    COUNT(*) AS ride_count
FROM divvy_trips_2026_08
GROUP BY member_casual
ORDER BY ride_count DESC;

-- 7. count the missing values in every column
--start_station_name(156,261), start_station_id(156,261), end_station_name(164,483), end_station_id(164483), end_lat(619), end_lng(619)
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(ride_id) AS null_ride_id,
    COUNT(*) - COUNT(rideable_type) AS null_rideable_type,
    COUNT(*) - COUNT(started_at) AS null_started_at,
    COUNT(*) - COUNT(ended_at) AS null_ended_at,
    COUNT(*) - COUNT(start_station_name) AS null_start_station_name,
    COUNT(*) - COUNT(start_station_id) AS null_start_station_id,
    COUNT(*) - COUNT(end_station_name) AS null_end_station_name,
    COUNT(*) - COUNT(end_station_id) AS null_end_station_id,
    COUNT(*) - COUNT(start_lat) AS null_start_lat,
    COUNT(*) - COUNT(start_lng) AS null_start_lng,
    COUNT(*) - COUNT(end_lat) AS null_end_lat,
    COUNT(*) - COUNT(end_lng) AS null_end_lng,
    COUNT(*) - COUNT(member_casual) AS null_member_casual
FROM divvy_trips_2025_09;

-- 8. calculate percentages of missing values
SELECT
    COUNT(*) AS total_rows,

    ROUND(
        100.0 * (COUNT(*) - COUNT(start_station_name)) / COUNT(*),
        2
    ) AS pct_null_start_station_name,

    ROUND(
        100.0 * (COUNT(*) - COUNT(start_station_id)) / COUNT(*),
        2
    ) AS pct_null_start_station_id,

    ROUND(
        100.0 * (COUNT(*) - COUNT(end_station_name)) / COUNT(*),
        2
    ) AS pct_null_end_station_name,

    ROUND(
        100.0 * (COUNT(*) - COUNT(end_station_id)) / COUNT(*),
        2
    ) AS pct_null_end_station_id,

    ROUND(
        100.0 * (COUNT(*) - COUNT(end_lat)) / COUNT(*),
        2
    ) AS pct_null_end_lat,

    ROUND(
        100.0 * (COUNT(*) - COUNT(end_lng)) / COUNT(*),
        2
    ) AS pct_null_end_lng
FROM divvy_trips_2025_09;