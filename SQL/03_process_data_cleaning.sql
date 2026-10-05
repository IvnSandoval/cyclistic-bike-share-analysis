select *
from divvy_trips_2025_11

-- 1. check duplicates ride IDs within each table
--no tables seem to have duplicates--
select
	ride_id,
	count(*) as occurrences
from divvy_trips_2025_09
group by ride_id
having count(*) > 1
order by occurrences desc;

-- 2. check the critical columns for Nulls
--In all tables there a zero counts of Null in each column--
SELECT
    COUNT(*) AS total_rows, --counting the total rows in the table--
    COUNT(*) FILTER (WHERE ride_id IS NULL) AS missing_ride_id,
    COUNT(*) FILTER (WHERE started_at IS NULL) AS missing_started_at,
    COUNT(*) FILTER (WHERE ended_at IS NULL) AS missing_ended_at,
    COUNT(*) FILTER (WHERE rideable_type IS NULL) AS missing_rideable_type,
    COUNT(*) FILTER (WHERE member_casual IS NULL) AS missing_member_casual
FROM divvy_trips_2026_08;

-- 3. check timestamp errors
--All tables but one have 0
--November 2025 has 29 invalid records--
select
    COUNT(*) AS invalid_time_records
from divvy_trips_2026_08
where ended_at <= started_at;
--investigate the 29 records--
SELECT
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    ended_at - started_at AS ride_length,
    member_casual
FROM divvy_trips_2025_11
WHERE ended_at <= started_at
ORDER BY ride_length;
--negative duration vs zero duration: all 29 records are negative duration--
SELECT
    COUNT(*) FILTER (WHERE ended_at < started_at) AS negative_duration,
    COUNT(*) FILTER (WHERE ended_at = started_at) AS zero_duration
FROM divvy_trips_2025_11;

-- 4. inspect ride durations
--All tables seem to have normal ride durations--
--November 2025 has minimun_ride(-00:54:47.688)--
select
    MIN(ended_at - started_at) as minimum_ride,
    MAX(ended_at - started_at) as maximum_ride,
    AVG(ended_at - started_at) as average_ride
from divvy_trips_2025_11;
--inspect the longest ride--
SELECT
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    ended_at - started_at AS ride_length,
    start_station_name,
    end_station_name,
    member_casual
FROM divvy_trips_2025_11
ORDER BY ride_length DESC
LIMIT 20;
--count the number of rides duration greater than or equal to 24hrs--
SELECT
    COUNT(*) AS rides_24_hours_or_longer
FROM divvy_trips_2025_11
WHERE ended_at - started_at >= INTERVAL '24 hours';

-- 5. check categorical values
--None of the types have inconsistent spelling, unexpected categories, blanks, etc.--
--rider types--
SELECT
    member_casual,
    COUNT(*)
FROM divvy_trips_2025_09
GROUP BY member_casual
ORDER BY COUNT(*) DESC;
--bike types--
SELECT
    rideable_type,
    COUNT(*)
FROM divvy_trips_2025_09
GROUP BY rideable_type
ORDER BY COUNT(*) DESC;

-- 6. Combine the 12 mothly tables
/*
CREATE TABLE divvy_trips_combined_raw AS
SELECT '2025-09' AS source_month, *
FROM divvy_trips_2025_09
UNION ALL
SELECT '2025-10', *
FROM divvy_trips_2025_10
UNION ALL
SELECT '2025-11', *
FROM divvy_trips_2025_11
UNION ALL
SELECT '2025-12', *
FROM divvy_trips_2025_12
UNION ALL
SELECT '2026-01', *
FROM divvy_trips_2026_01
UNION ALL
SELECT '2026-02', *
FROM divvy_trips_2026_02
UNION ALL
SELECT '2026-03', *
FROM divvy_trips_2026_03
UNION ALL
SELECT '2026-04', *
FROM divvy_trips_2026_04
UNION ALL
SELECT '2026-05', *
FROM divvy_trips_2026_05
UNION ALL
SELECT '2026-06', *
FROM divvy_trips_2026_06
UNION ALL
SELECT '2026-07', *
FROM divvy_trips_2026_07
UNION ALL
SELECT '2026-08', *
FROM divvy_trips_2026_08;
*/

select *
from divvy_trips_combined_raw
--verify all 12 source months are included--
SELECT
    source_month,
    COUNT(*) AS number_of_rows
FROM divvy_trips_combined_raw
GROUP BY source_month
ORDER BY source_month;
--check for duplicates--
SELECT
    ride_id,
    COUNT(*) AS occurrences
FROM divvy_trips_combined_raw
GROUP BY ride_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;
--inspect the duplicate records--
WITH duplicate_ids AS (
    SELECT ride_id
    FROM divvy_trips_combined_raw
    GROUP BY ride_id
    HAVING COUNT(*) > 1
)
SELECT
    d.source_month,
    d.ride_id,
    d.rideable_type,
    d.started_at,
    d.ended_at,
    d.start_station_name,
    d.start_station_id,
    d.end_station_name,
    d.end_station_id,
    d.start_lat,
    d.start_lng,
    d.end_lat,
    d.end_lng,
    d.member_casual
FROM divvy_trips_combined_raw AS d
JOIN duplicate_ids AS x
    ON d.ride_id = x.ride_id
ORDER BY d.ride_id, d.source_month;
--find which monthly fiels contain them--
--all 35 duplicated ride_ids occur b/w April 2026 and May 2026
SELECT
    source_month,
    COUNT(*) AS duplicated_rows
FROM divvy_trips_combined_raw
WHERE ride_id IN (
    SELECT ride_id
    FROM divvy_trips_combined_raw
    GROUP BY ride_id
    HAVING COUNT(*) > 1
)
GROUP BY source_month
ORDER BY source_month;
--final duplication verification--
--each ride_id occurs twice, but the two copies contain same trip info--
SELECT
    ride_id,
    COUNT(*) AS number_of_rows,
    COUNT(
        DISTINCT ROW(
            rideable_type,
            started_at,
            ended_at,
            start_station_name,
            start_station_id,
            end_station_name,
            end_station_id,
            start_lat,
            start_lng,
            end_lat,
            end_lng,
            member_casual
        )
    ) AS distinct_versions
FROM divvy_trips_combined_raw
GROUP BY ride_id
HAVING COUNT(*) > 1
ORDER BY ride_id;

-- 7. create the cleaned table
/*
CREATE TABLE divvy_trips_clean AS
WITH deduplicated AS (	--keeps one row per ride_id--
    SELECT DISTINCT ON (ride_id)
        *
    FROM divvy_trips_combined_raw
    ORDER BY ride_id, source_month
)
SELECT
    source_month,
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual,
    CASE
        WHEN ended_at > started_at	--creates the required ride_length--
        THEN ended_at - started_at	--if ride has valid end time after start time, calculate duration normally--
        ELSE null					--but if end_at <= start_at, the new ride_length value become NULL--
    END AS ride_length,
    EXTRACT(DOW FROM started_at)::INTEGER + 1	--creates day of the week--
        AS day_of_week
FROM deduplicated;
*/

select *
from divvy_trips_clean

-- 8. inspect the clean table
--check how many rows were removed--
SELECT
    (SELECT COUNT(*) FROM divvy_trips_combined_raw) AS raw_rows,
    (SELECT COUNT(*) FROM divvy_trips_clean) AS clean_rows,
    (SELECT COUNT(*) FROM divvy_trips_combined_raw)
      - (SELECT COUNT(*) FROM divvy_trips_clean) AS rows_removed;
--check that no duplicate ride_ids remain--
SELECT
    ride_id,
    COUNT(*) AS occurrences
FROM divvy_trips_clean
GROUP BY ride_id
HAVING COUNT(*) > 1;
--check the negative durations--
SELECT
    COUNT(*) AS missing_ride_length	--there should be 29 now called NULL--
FROM divvy_trips_clean
WHERE ride_length IS NULL;
--check that there are no negative durations--
SELECT
    COUNT(*) AS negative_ride_lengths	--there are 0 negative durations--
FROM divvy_trips_clean
WHERE ride_length < INTERVAL '0 seconds';
--verify day_of_week--
SELECT
    day_of_week,
    COUNT(*) AS number_of_rides
FROM divvy_trips_clean
GROUP BY day_of_week
ORDER BY day_of_week;