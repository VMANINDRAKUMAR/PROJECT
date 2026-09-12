LOAD DATA LOCAL INFILE 'C:/Users/V MANINDRA KUMAR/Desktop/PROJECT/earthquake_final.csv'
INTO TABLE earthquake_import
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @time,
    latitude,
    longitude,
    depth,
    mag,
    magType,
    nst,
    gap,
    dmin,
    rms,
    net,
    id,
    @updated,
    place,
    type,
    horizontalError,
    depthError,
    magError,
    magNst,
    status,
    locationSource,
    magSource,
    types
)
SET
    time = STR_TO_DATE(LEFT(@time, 26), '%Y-%m-%d %H:%i:%s.%f'),
    updated = STR_TO_DATE(LEFT(@updated, 26), '%Y-%m-%d %H:%i:%s.%f');









SELECT id,
       place,
       country,
       mag
FROM earthquakes
ORDER BY mag DESC
LIMIT 10;

DESCRIBE earthquakes;

SELECT id,
       place,
       mag
FROM earthquakes
ORDER BY mag DESC
LIMIT 10;

select count(*) as total_rows
from earthquakes;

SHOW columns from earthquakes;

LOAD DATA LOCAL INFILE 'C:/Users/V MANINDRA KUMAR/Desktop/PROJECT/earthquake_final.csv'
INTO TABLE earthquakes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @time,
    latitude,
    longitude,
    depth,
    mag,
    magType,
    @nst,
    @gap,
    @dmin,
    @rms,
    net,
    id,
    @updated,
    place,
    type,
    @horizontalError,
    @depthError,
    @magError,
    @magNst,
    status,
    @locationSource,
    @magSource
)
SET
    time = STR_TO_DATE(@time, '%Y-%m-%d %H:%i:%s.%f+00:00'),
    updated = STR_TO_DATE(@updated, '%Y-%m-%d %H:%i:%s.%f+00:00');

SHOW GLOBAL VARIABLES LIKE 
'local_infile';

SET GLOBAL local_infile = ON;

SHOW GLOBAL VARIABLES LIKE 
'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/V MANINDRA KUMAR/Desktop/PROJECT/earthquake_final.csv'
INTO TABLE earthquakes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @time,
    latitude,
    longitude,
    depth,
    mag,
    magType,
    @nst,
    @gap,
    @dmin,
    @rms,
    net,
    id,
    @updated,
    place,
    type,
    @horizontalError,
    @depthError,
    @magError,
    @magNst,
    status,
    @locationSource,
    @magSource
)
SET
    time = STR_TO_DATE(@time, '%Y-%m-%d %H:%i:%s.%f+00:00'),
    updated = STR_TO_DATE(@updated, '%Y-%m-%d %H:%i:%s.%f+00:00');

select count(*) as total_rows
from earthquakes;



SELECT
    YEAR(time) AS year,
    COUNT(*) AS earthquake_count
FROM earthquakes
GROUP BY YEAR(time)
ORDER BY year;

SELECT
    YEAR(time) AS year,
    COUNT(*) AS earthquake_count
FROM earthquakes
WHERE time IS NOT NULL
GROUP BY YEAR(time)
ORDER BY year;

# 1. Top 10 strongest Earthquakes:

SELECT id,
       place,
       mag
FROM earthquakes
ORDER BY mag DESC
LIMIT 10;

# 2. Top 10 Deepest Earthquakes:

SELECT id,
       place,
       depth
FROM earthquakes
ORDER BY depth DESC
LIMIT 10;

# 3. Shallow Earthquakes (< 50 km) with Magnitude > 7.5:

SELECT *
FROM earthquakes
WHERE depth < 50
AND mag > 7.5;

# 4. Average Depth by Country

SELECT net,
       ROUND(AVG(depth),2) AS average_depth
FROM earthquakes
GROUP BY net
ORDER BY average_depth DESC;

# 5. Average Magnitude by Magnitude Type

SELECT magType,
       ROUND(AVG(mag),2) AS average_magnitude
FROM earthquakes
GROUP BY magType
ORDER BY average_magnitude DESC;

# 6. Year with Most Earthquakes

SELECT 
    YEAR(time) AS year,
    COUNT(*) AS earthquake_count
FROM earthquakes
GROUP BY YEAR(time)
ORDER BY earthquake_count DESC;


# 7. Month with Highest Number of Earthquakes

SELECT 
    MONTH(time) AS month,
    COUNT(*) AS earthquake_count
FROM earthquakes
GROUP BY MONTH(time)
ORDER BY earthquake_count DESC;

# 8. Day of Week with Most Earthquakes

SELECT 
    DAYNAME(time) AS day_of_week,
    COUNT(*) AS earthquake_count
FROM earthquakes
GROUP BY DAYOFWEEK(time), DAYNAME(time)
ORDER BY earthquake_count DESC;

# 9. Number of Earthquakes per Hour:

SELECT 
    HOUR(time) AS hour,
    COUNT(*) AS earthquake_count
FROM earthquakes
GROUP BY HOUR(time)
ORDER BY hour;


# 10. Most Active Reporting Network:

SELECT 
    net,
    COUNT(*) AS earthquake_count
FROM earthquakes
GROUP BY net
ORDER BY earthquake_count DESC
LIMIT 1;

# 11. Top 5 Places with Highest Casualties - Column record not have in data set

# 12. Total Estimated Economic Loss per Continent - Column record not have in data set

# 13. Average Economic Loss by Alert Level - Column record not have in data set

# 14. Reviewed vs Automatic Earthquakes:

SELECT
    status,
    COUNT(*) AS earthquake_count
FROM earthquakes
GROUP BY status
ORDER BY earthquake_count DESC;

# 15. Count by Earthquake Type:

SELECT
    type,
    COUNT(*) AS earthquake_count
FROM earthquakes
GROUP BY type
ORDER BY earthquake_count DESC;


# 16. Number of Earthquakes by Data Type: Column is not in data set

# 17. Average RMS and GAP:

SELECT
    ROUND(AVG(rms), 3) AS average_rms,
    ROUND(AVG(gap), 2) AS average_gap
FROM earthquake_import;

# 18. Earthquakes with High Station Coverage: 

SELECT
    id,
    place,
    mag,
    nst
FROM earthquake_import
WHERE nst > 50
ORDER BY nst DESC;

# Tsunami & Alert Analysis:

# 19. Number of Tsunamis Triggered Per Year: Column is not in data set

# 20. Count Earthquakes by Alert Level - Column is not in data set

Seismic Patterns & Trends

# 21. Top 5 Countries by Average Magnitude:

SELECT
    country,
    ROUND(AVG(mag), 2) AS average_magnitude,
    COUNT(*) AS earthquake_count
FROM earthquakes
WHERE country IS NOT NULL
GROUP BY country
HAVING COUNT(*) >= 5
ORDER BY average_magnitude DESC
LIMIT 5;


SELECT location_source, COUNT(*) AS earthquake_count
FROM earthquakes
GROUP BY location_source
ORDER BY earthquake_count DESC
LIMIT 10;


DESCRIBE earthquakes;

SELECT place FROM earthquakes WHERE place IS NOT NULL LIMIT 20;

ALTER TABLE earthquakes
ADD COLUMN country VARCHAR(100);

DESCRIBE earthquakes;

SELECT COUNT(*) AS total_earthquakes
FROM earthquakes;

SELECT
    place,
    REGEXP_SUBSTR(place, '[^,]+$') AS country
FROM earthquakes
WHERE place IS NOT NULL
LIMIT 20;

UPDATE earthquakes
SET country = REGEXP_SUBSTR(place, '[^,]+$')
WHERE place IS NOT NULL;

# 21. Top 5 Countries by Average Magnitude:

SELECT
    country,
    ROUND(AVG(mag), 2) AS average_magnitude,
    COUNT(*) AS earthquake_count
FROM earthquakes
WHERE country IS NOT NULL
  AND mag IS NOT NULL
GROUP BY country
HAVING COUNT(*) >= 5
ORDER BY average_magnitude DESC
LIMIT 5;


# 22. Countries with Both Shallow and Deep Earthquakes in the Same Month:

SELECT
    country,
    YEAR(time) AS year,
    MONTH(time) AS month
FROM earthquakes
WHERE country IS NOT NULL
  AND depth IS NOT NULL
GROUP BY country, YEAR(time), MONTH(time)
HAVING
    MIN(depth) < 70
    AND MAX(depth) >= 300
ORDER BY country, year, month;


# 23. Year-over-Year Growth Rate:

WITH yearly_counts AS (
    SELECT
        YEAR(time) AS year,
        COUNT(*) AS earthquake_count
    FROM earthquakes
    WHERE time IS NOT NULL
    GROUP BY YEAR(time)
),
growth AS (
    SELECT
        year,
        earthquake_count,
        LAG(earthquake_count) OVER (ORDER BY year) AS previous_year_count
    FROM yearly_counts
)
SELECT
    year,
    earthquake_count,
    previous_year_count,
    ROUND(
        (earthquake_count - previous_year_count)
        / previous_year_count * 100,
        2
    ) AS yoy_growth_percentage
FROM growth
WHERE previous_year_count IS NOT NULL
ORDER BY year;

SELECT
    YEAR(time) AS year,
    COUNT(*) AS earthquake_count
FROM earthquakes
WHERE time IS NOT NULL
GROUP BY YEAR(time)
ORDER BY year;


# 24. Three Most Seismically Active Regions:

WITH region_stats AS (
    SELECT
        country,
        COUNT(*) AS earthquake_count,
        AVG(mag) AS average_magnitude
    FROM earthquakes
    WHERE country IS NOT NULL
    GROUP BY country
),

scored_regions AS (
    SELECT
        country,
        earthquake_count,
        ROUND(average_magnitude, 2) AS average_magnitude,
        ROUND(
            earthquake_count * average_magnitude,
            2
        ) AS seismic_score
    FROM region_stats
)

SELECT
    country,
    earthquake_count,
    average_magnitude,
    seismic_score
FROM scored_regions
ORDER BY seismic_score DESC
LIMIT 3;


#Depth, Location & Distance Analysis:

#25. Average Depth Near the Equator:

SELECT
    country,
    COUNT(*) AS earthquake_count,
    ROUND(AVG(depth), 2) AS average_depth
FROM earthquakes
WHERE latitude BETWEEN -5 AND 5
AND country IS NOT NULL
GROUP BY country
ORDER BY average_depth DESC;


# 26. Countries with Highest Shallow-to-Deep Ratio:

SELECT
    country,

    SUM(
        CASE
            WHEN depth < 70 THEN 1
            ELSE 0
        END
    ) AS shallow_count,

    SUM(
        CASE
            WHEN depth >= 300 THEN 1
            ELSE 0
        END
    ) AS deep_count,

    ROUND(
        SUM(
            CASE
                WHEN depth < 70 THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN depth >= 300 THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS shallow_deep_ratio

FROM earthquakes
WHERE country IS NOT NULL
GROUP BY country
HAVING deep_count > 0
ORDER BY shallow_deep_ratio DESC;

# 27. Average Magnitude: Tsunami vs No Tsunami: Column is not in data set

# 28. Lowest Data Reliability Using RMS and GAP:


SELECT
    COUNT(*) AS total_rows,
    COUNT(rms) AS rms_available,
    COUNT(gap) AS gap_available
FROM earthquakes;

SELECT
    id,
    place,
    rms,
    gap
FROM earthquakes
WHERE rms IS NOT NULL
   OR gap IS NOT NULL
LIMIT 20;

SELECT
    id,
    place,
    mag,
    rms,
    gap,
    ROUND(
        (COALESCE(rms, 0) + COALESCE(gap, 0)),
        2
    ) AS error_score
FROM earthquakes
ORDER BY error_score DESC
LIMIT 20;

# 29. Consecutive Earthquakes Within 50 km and 1 Hour:

WITH ordered_events AS (

    SELECT
        id,
        time,
        latitude,
        longitude,
        place,

        LEAD(id) OVER (
            ORDER BY time
        ) AS next_id,

        LEAD(time) OVER (
            ORDER BY time
        ) AS next_time,

        LEAD(latitude) OVER (
            ORDER BY time
        ) AS next_latitude,

        LEAD(longitude) OVER (
            ORDER BY time
        ) AS next_longitude

    FROM earthquakes
)

SELECT
    id AS earthquake_1,
    next_id AS earthquake_2,
    time AS earthquake_1_time,
    next_time AS earthquake_2_time,

    TIMESTAMPDIFF(
        MINUTE,
        time,
        next_time
    ) AS time_difference_minutes,

    ROUND(
        6371 * 2 * ASIN(
            SQRT(
                POWER(
                    SIN(
                        RADIANS(next_latitude - latitude) / 2
                    ),
                    2
                )
                +
                COS(RADIANS(latitude))
                * COS(RADIANS(next_latitude))
                * POWER(
                    SIN(
                        RADIANS(next_longitude - longitude) / 2
                    ),
                    2
                )
            )
        ),
        2
    ) AS distance_km

FROM ordered_events

WHERE next_id IS NOT NULL

AND TIMESTAMPDIFF(
    MINUTE,
    time,
    next_time
) <= 60

HAVING distance_km <= 50

ORDER BY time_difference_minutes;

# 30. Regions with Highest Frequency of Deep-Focus Earthquakes:

SELECT
    country,
    COUNT(*) AS deep_earthquake_count,
    ROUND(AVG(depth), 2) AS average_depth
FROM earthquakes
WHERE depth > 300
AND country IS NOT NULL
GROUP BY country
ORDER BY deep_earthquake_count DESC
LIMIT 10;


# 13. Number of Earthquakes by Data Type: Column is not in data set

# 14. Average RMS and GAP: Column is not in data set

# 18. Earthquakes with High Station Coverage: Column is not in data set




















DESCRIBE earthquakes;

ALTER Table earthquakes
ADD COLUMN nst INT NULL,
ADD COLUMN gap DOUBLE NULL,
ADD COLUMN dmin DOUBLE NULL,
ADD COLUMN rms DOUBLE NULL;

SELECT nst, gap, dmin, rms FROM earthquakes LIMIT 10;

CREATE TABLE earthquake_import (
    id VARCHAR(50),
    time DATETIME,
    updated DATETIME,
    latitude DOUBLE,
    longitude DOUBLE,
    depth DOUBLE,
    mag DOUBLE,
    magType VARCHAR(20),
    nst INT,
    gap DOUBLE,
    dmin DOUBLE,
    rms DOUBLE,
    net VARCHAR(20),
    place TEXT,
    type VARCHAR(50)
);

DROP TABLE earthquake_import;

CREATE TABLE earthquake_import (
    time DATETIME,
    latitude DOUBLE,
    longitude DOUBLE,
    depth DOUBLE,
    mag DOUBLE,
    magType VARCHAR(20),
    nst INT,
    gap DOUBLE,
    dmin DOUBLE,
    rms DOUBLE,
    net VARCHAR(20),
    id VARCHAR(50),
    updated DATETIME,
    place TEXT,
    type VARCHAR(50),
    horizontalError DOUBLE,
    depthError DOUBLE,
    magError DOUBLE,
    magNst INT,
    status VARCHAR(30),
    locationSource VARCHAR(20),
    magSource VARCHAR(20),
    types TEXT
);


LOAD DATA LOCAL INFILE 'C:/Users/V MANINDRA KUMAR/Desktop/PROJECT/earthquake_final.csv'
INTO TABLE earthquake_import
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @time,
    latitude,
    longitude,
    depth,
    mag,
    magType,
    nst,
    gap,
    dmin,
    rms,
    net,
    id,
    @updated,
    place,
    type,
    horizontalError,
    depthError,
    magError,
    magNst,
    status,
    locationSource,
    magSource,
    types
)
SET
    time = STR_TO_DATE(LEFT(@time, 26), '%Y-%m-%d %H:%i:%s.%f'),
    updated = STR_TO_DATE(LEFT(@updated, 26), '%Y-%m-%d %H:%i:%s.%f');

SELECT nst, gap, dmin, rms, types FROM earthquake_import LIMIT 10;














