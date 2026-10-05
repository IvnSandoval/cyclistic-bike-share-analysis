/*
Cyclistic Bike-Share Case Study
Analyze Phase

Business Question:
How do annual members and casual riders use Cyclistic bikes differently?

Source Table:
divvy_trips_clean
*/

select *
from divvy_trips_clean

/* 1. Confirm the analysis population */
--Count the total number of rows in divvy_trips_clean--
SELECT
    COUNT(*) AS total_rides
FROM divvy_trips_clean;
--Count members vs casuals--
--There is a higher number of members than casuals
SELECT
    member_casual,
    COUNT(*) AS total_rides
FROM divvy_trips_clean
GROUP BY member_casual
ORDER BY total_rides DESC;
--Calculate percentages of members vs causals--
--members account for more trips
SELECT
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),	--calculates each groups percentage of all rides
        2
    ) AS percentage_of_rides
FROM divvy_trips_clean
GROUP BY member_casual
ORDER BY total_rides DESC;
--------------------------------------------------------------------------------------------------------------------------
/* 2. Compare ride duration */
--Do casual riders tend to ride longer than members?--
--Data may be skewed, may contain outliers, etc.
--The Minimum in near 0min for both rider types
--The Average is 20.7min and 12.37min for casual and members
--The Maximum for both types is around 1560min; extremly large duration relative to Min and Avg; may indicate outliers
--Do casual riders tend to ride longer than member?
SELECT
    member_casual,
    COUNT(ride_length) AS rides_with_valid_duration,
    ROUND(
        AVG(EXTRACT(EPOCH FROM ride_length) / 60.0),
        2
    ) AS avg_ride_minutes,
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM ride_length) / 60.0		--Added the Median from below onto this
        )::numeric,
        2
    ) AS median_ride_minutes,
    ROUND(
        MIN(EXTRACT(EPOCH FROM ride_length) / 60.0),
        2
    ) AS min_ride_minutes,
    ROUND(
        MAX(EXTRACT(EPOCH FROM ride_length) / 60.0),
        2
    ) AS max_ride_minutes
FROM divvy_trips_clean
WHERE ride_length IS NOT NULL
GROUP BY member_casual;
--Calculate the Median--
--Casual: 10.86min
--Member: 8.55min
SELECT
    member_casual,
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM ride_length) / 60.0
        )::numeric,
        2
    ) AS median_ride_minutes
FROM divvy_trips_clean
WHERE ride_length IS NOT NULL
GROUP BY member_casual;
--------------------------------------------------------------------------------------------------------------------------
/* 3. Compare usage by day of week */
--Highest causal usage on Saturday (21,14%)
--Highest member usage on Wednesday (15.98%)
SELECT
    member_casual,
    day_of_week,
    CASE day_of_week
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS day_name,
    COUNT(*) AS total_rides
FROM divvy_trips_clean
GROUP BY member_casual, day_of_week
ORDER BY member_casual, day_of_week;
--calculate percentage of each types trips occuring on each day--
--casuals are more concentrated on weekedns
--members highest usage occure Tuesday-Thursday
SELECT
    member_casual,
    day_of_week,
    CASE day_of_week
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS day_name,
    COUNT(*) AS total_rides,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY member_casual),
        2
    ) AS pct_of_rider_type
FROM divvy_trips_clean
GROUP BY member_casual, day_of_week
ORDER BY member_casual, day_of_week;
--------------------------------------------------------------------------------------------------------------------------
/* 4. Compare average duration by day */
--casual types have higher average duration on Sunday(24.29min)->decreases until Wednesday(17.25min), then increases
--member types have higher average duration on Saturday(13.60min)->decreases until Wednesday(11.85min), then increases
--Does the difference in ride duration between members and casual riders change depending on the day?
SELECT
    member_casual,
    day_of_week,
    CASE day_of_week
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS day_name,
    ROUND(
        AVG(EXTRACT(EPOCH FROM ride_length) / 60.0),
        2
    ) AS avg_ride_minutes,
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM ride_length) / 60.0		--Added the Median from below onto this
        )::numeric,
        2
    ) AS median_ride_minutes
FROM divvy_trips_clean
WHERE ride_length IS NOT NULL
GROUP BY member_casual, day_of_week
ORDER BY member_casual, day_of_week;
--Compare median ride duration by day--
--Does the typical ride duration show the same weekly pattern?
--median casual: Saturday (12.64min)
--meidan members: Saturday (9.36min)
SELECT
    member_casual,
    day_of_week,
    CASE day_of_week
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS day_name,
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM ride_length) / 60.0
        )::numeric,
        2
    ) AS median_ride_minutes
FROM divvy_trips_clean
WHERE ride_length IS NOT NULL
GROUP BY member_casual, day_of_week
ORDER BY member_casual, day_of_week;
--------------------------------------------------------------------------------------------------------------------------
/* 5. Monthly patterns */
--How many rides were taken each month by members and casuals?--
--Records in August 2025, with extremly low values for causal and member
--Maybe there aren't a lot of records under start_at column with August 2025
SELECT
    DATE_TRUNC('month', started_at)::date AS month,
    member_casual,
    COUNT(*) AS total_rides
FROM divvy_trips_clean
GROUP BY
    DATE_TRUNC('month', started_at),
    member_casual
ORDER BY month, member_casual;
--Analysis period: September 2025 through August 2026--
SELECT
    DATE_TRUNC('month', started_at)::date AS month,
    TO_CHAR(DATE_TRUNC('month', started_at), 'Mon YYYY') AS month_name,
    member_casual,
    COUNT(*) AS total_rides
FROM divvy_trips_clean
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY
    DATE_TRUNC('month', started_at),
    member_casual
ORDER BY
    month,
    member_casual;
--calculate percentages within each rider groups--
--Which months have the most members rides?
--Which months have the most casual rides?
--Does causal ridership appear more seasonal?
--Does member ridership remain relatively stable throughout more of the year?
--Casual: number of rides decrease starting August; begins to increase by February; reaches its highest by July
--Member: number of rides decrease starting August; begins to increase by December; reaches its highest by August
SELECT
    DATE_TRUNC('month', started_at)::date AS month,
    member_casual,
    COUNT(*) AS total_rides,	--takes each ride's started_at date and time and reduces it to the first day of that month
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY member_casual),
        2
    ) AS pct_of_rider_type
FROM divvy_trips_clean
GROUP BY
    DATE_TRUNC('month', started_at),
    member_casual
ORDER BY member_casual, month;
--calculate percentages within analysis period: September 2025 through August 2026--
--both rider types use Cyclistic much more during the warmer months and less during winter
--Casual ridership reached its lowest point in January 2026 with 24,740 rides (1.15% of casual rides)
--Casual ridership peaked in July 2026 with 357,779 rides (16.56% of casual rides
--Member ridership was lowest in December 2025 with 112,455 rides (2.84% of member rides).
--Member ridership peaked in August 2026 with 521,066 rides (13.17% of member rides).
--The seasonal change was more pronounced among casual riders, suggesting casual usage is more
	--seasonally concentrated than member usage
SELECT
    DATE_TRUNC('month', started_at)::date AS month,
    TO_CHAR(DATE_TRUNC('month', started_at), 'Mon YYYY') AS month_name,
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY member_casual),
        2
    ) AS pct_of_rider_type
FROM divvy_trips_clean
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY
    DATE_TRUNC('month', started_at),
    member_casual
ORDER BY
    month,
    member_casual;
--------------------------------------------------------------------------------------------------------------------------
/* 6. Time of day usage */
--number of rides from casuals and members each hour fo the day--
--both groups reach their highest ride count at 5:00pm (hour17)
--Casual: 204,515 rides
--Members: 426,718 rides
SELECT
    EXTRACT(HOUR FROM started_at)::int AS hour_of_day,		--pulls just the hour from each rides starting timestamp
    member_casual,											--gives hours 0-23
    COUNT(*) AS total_rides
FROM divvy_trips_clean
GROUP BY
    EXTRACT(HOUR FROM started_at),
    member_casual
ORDER BY hour_of_day, member_casual;
--number of rides each hour of the day with analysis period September 2025 through August 2026--
SELECT
    EXTRACT(HOUR FROM started_at)::int AS hour_of_day,
    member_casual,
    COUNT(*) AS total_rides
FROM divvy_trips_clean
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY
    EXTRACT(HOUR FROM started_at),
    member_casual
ORDER BY
    hour_of_day,
    member_casual;
--group rides into broader time of day categories--
--Casual: number of rides at its highest during the evening, lowest during the morning
--Members: number of rides at its highest during the evening, lowest during the night
SELECT
    member_casual,
    CASE
        WHEN EXTRACT(HOUR FROM started_at) BETWEEN 5 AND 10		--creates a new category based on the hour a ride started
            THEN 'Morning'
        WHEN EXTRACT(HOUR FROM started_at) BETWEEN 11 AND 15
            THEN 'Midday'
        WHEN EXTRACT(HOUR FROM started_at) BETWEEN 16 AND 19
            THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    COUNT(*) AS total_rides
FROM divvy_trips_clean
GROUP BY member_casual, time_of_day
ORDER BY member_casual, total_rides DESC;
--group rides into broader time of day categories with analysis period--
--Evening was the most common time period for both rider types.
--34.57% of member rides occurred in the evening, compared with 32.47% of casual rides.
--Members had substantially more of their rides in the morning: 25.18% compared with 15.56% for casual riders.
--Casual riders were more concentrated during midday and night.
--Hourly results showed a noticeable member peak around 8:00 AM and a larger peak around 5:00 PM.
--Casual usage increased more gradually through the day and also peaked around 5:00 PM.
--These results show different daily usage patterns, but the dataset does not identify the purpose of individual trips.
SELECT
    member_casual,
    CASE
        WHEN EXTRACT(HOUR FROM started_at) BETWEEN 5 AND 10
            THEN 'Morning'
        WHEN EXTRACT(HOUR FROM started_at) BETWEEN 11 AND 15
            THEN 'Midday'
        WHEN EXTRACT(HOUR FROM started_at) BETWEEN 16 AND 19
            THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    COUNT(*) AS total_rides,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY member_casual),
        2
    ) AS pct_of_rider_type
FROM divvy_trips_clean
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY
    member_casual,
    time_of_day
ORDER BY
    member_casual,
    total_rides DESC;
--------------------------------------------------------------------------------------------------------------------------
/* 7. Bike type */
--Casual and members bike type preference--
--casuals and members used eletricbikes for a larger share of rides
--casuals have a relatively higher number of e-bkie usage than members
SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS total_rides,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY member_casual),
        2
    ) AS pct_of_rider_type
FROM divvy_trips_clean
GROUP BY member_casual, rideable_type
ORDER BY member_casual, total_rides DESC;
--Analysis peirod: Sep 2025-Aug 2026--
--Electric bikes accounted for the majority of rides for both casual riders and members.
--73.60% of casual rides used electric bikes, compared with 68.06% of member rides.
--Classic bikes accounted for 26.40% of casual rides and 31.94% of member rides.
--Casual riders therefore had a somewhat larger share of electric-bike usage than members.
--These results describe actual bike usage and should not be interpreted as proof of rider preference.
SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS total_rides,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY member_casual),
        2
    ) AS pct_of_rider_type
FROM divvy_trips_clean
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY
    member_casual,
    rideable_type
ORDER BY
    member_casual,
    total_rides DESC;
--------------------------------------------------------------------------------------------------------------------------
/* 8. Station patterns */
SELECT
    member_casual,
    start_station_name,
    COUNT(*) AS total_rides
FROM divvy_trips_clean
WHERE start_station_name IS NOT NULL
GROUP BY member_casual, start_station_name
ORDER BY member_casual, total_rides DESC;
--Question:Do casual riders and members tend to start rides at different stations?--
--The top starting stations differed substantially between rider types.
--Navy Pier was the most-used starting station among casual riders, with 51,740 rides.
--Many of the highest-ranked casual stations were located near the lakefront or well-known destination areas,
	--including Millennium Park, Shedd Aquarium, Theater on the Lake, DuSable Harbor, and Field Museum.
--Member top stations were primarily street-intersection stations, including Canal St & Madison St, Clinton St & Jackson Blvd,
	--and several Wells St locations.
--Navy Pier was the only station appearing in both groups' top 10.
--This suggests that casual riders and members have different spatial patterns in where rides begin.
--Station analysis includes only rides with a known start_station_name, so these results do not represent every ride in the dataset.
WITH station_counts AS (
    SELECT
        member_casual,
        start_station_name,
        COUNT(*) AS total_rides
    FROM divvy_trips_clean
    WHERE start_station_name IS NOT NULL
      AND started_at >= '2025-09-01'
      AND started_at <  '2026-09-01'
    GROUP BY
        member_casual,
        start_station_name
),
ranked_stations AS (
    SELECT
        member_casual,
        start_station_name,
        total_rides,
        ROUND(
            100.0 * total_rides /
            SUM(total_rides) OVER (PARTITION BY member_casual),
            2
        ) AS pct_of_known_station_rides,
        ROW_NUMBER() OVER (
            PARTITION BY member_casual
            ORDER BY total_rides DESC
        ) AS station_rank
    FROM station_counts
)
SELECT
    member_casual,
    station_rank,
    start_station_name,
    total_rides,
    pct_of_known_station_rides
FROM ranked_stations
WHERE station_rank <= 10
ORDER BY
    member_casual,
    station_rank;