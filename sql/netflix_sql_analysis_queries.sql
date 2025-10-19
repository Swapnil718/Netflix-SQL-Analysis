CREATE DATABASE netflix_db;

USE netflix_db;

-- Creating table for importing data from CSV(to match the CSV)
CREATE TABLE netflix_titles (
  show_id      VARCHAR(20),
  type         VARCHAR(20),
  title        VARCHAR(512),
  director     VARCHAR(1024),
  cast         VARCHAR(4000),
  country      VARCHAR(2000),
  date_added   VARCHAR(64),
  release_year INT,
  rating       VARCHAR(50),D
  duration     VARCHAR(100),
  listed_in    VARCHAR(2000),
  description  TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SELECT * FROM netflix_titles LIMIT 5;

CREATE OR REPLACE VIEW netflix_clean AS
    SELECT 
        show_id,
        type,
        title,
        director,
        cast,
        country,
        date_added,
        STR_TO_DATE(date_added, '%M %e, %Y') AS date_added_dt,
        release_year,
        rating,
        duration,
        CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS duration_value,
        CASE
            WHEN LOWER(duration) LIKE '%season%' THEN 'season'
            WHEN LOWER(duration) LIKE '%min%' THEN 'min'
            ELSE NULL
        END AS duration_unit,
        CASE
            WHEN
                LOWER(type) = 'tv show'
                    AND LOWER(duration) LIKE '%season%'
            THEN
                CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)
            ELSE NULL
        END AS seasons,
        listed_in,
        description
    FROM
        netflix_titles;
        

SELECT * FROM netflix_clean LIMIT 10;

-- 1) Create once; safe to re-run
CREATE TABLE IF NOT EXISTS helper_nums (n INT PRIMARY KEY);

-- 2) Populate 1..200 (enough for country/genres/cast lists)
INSERT IGNORE INTO helper_nums (n)
SELECT seq.n
FROM (
  SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
  SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
  SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL
  SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL
  SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL
  SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30 UNION ALL
  SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35 UNION ALL
  SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL SELECT 40 UNION ALL
  SELECT 41 UNION ALL SELECT 42 UNION ALL SELECT 43 UNION ALL SELECT 44 UNION ALL SELECT 45 UNION ALL
  SELECT 46 UNION ALL SELECT 47 UNION ALL SELECT 48 UNION ALL SELECT 49 UNION ALL SELECT 50
) AS seq
LEFT JOIN helper_nums h ON h.n = seq.n
WHERE h.n IS NULL;

-- (Optional) top up to 200
INSERT IGNORE INTO helper_nums (n)
SELECT x.n FROM (
  SELECT 51 n UNION ALL SELECT 52 UNION ALL SELECT 53 UNION ALL SELECT 54 UNION ALL SELECT 55 UNION ALL
  SELECT 56 UNION ALL SELECT 57 UNION ALL SELECT 58 UNION ALL SELECT 59 UNION ALL SELECT 60 UNION ALL
  SELECT 61 UNION ALL SELECT 62 UNION ALL SELECT 63 UNION ALL SELECT 64 UNION ALL SELECT 65 UNION ALL
  SELECT 66 UNION ALL SELECT 67 UNION ALL SELECT 68 UNION ALL SELECT 69 UNION ALL SELECT 70 UNION ALL
  SELECT 71 UNION ALL SELECT 72 UNION ALL SELECT 73 UNION ALL SELECT 74 UNION ALL SELECT 75 UNION ALL
  SELECT 76 UNION ALL SELECT 77 UNION ALL SELECT 78 UNION ALL SELECT 79 UNION ALL SELECT 80 UNION ALL
  SELECT 81 UNION ALL SELECT 82 UNION ALL SELECT 83 UNION ALL SELECT 84 UNION ALL SELECT 85 UNION ALL
  SELECT 86 UNION ALL SELECT 87 UNION ALL SELECT 88 UNION ALL SELECT 89 UNION ALL SELECT 90 UNION ALL
  SELECT 91 UNION ALL SELECT 92 UNION ALL SELECT 93 UNION ALL SELECT 94 UNION ALL SELECT 95 UNION ALL
  SELECT 96 UNION ALL SELECT 97 UNION ALL SELECT 98 UNION ALL SELECT 99 UNION ALL SELECT 100
) x;

-- Explode countries into one per row
SELECT
  nc.show_id,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(nc.country, ',', h.n), ',', -1)) AS country_single
FROM netflix_clean nc
JOIN helper_nums h
  ON h.n <= 1 + LENGTH(nc.country) - LENGTH(REPLACE(nc.country, ',', ''))
WHERE nc.country IS NOT NULL AND nc.country <> '';

-- Q1) Count Movies vs TV Shows
SELECT type, COUNT(*) AS count_items
FROM netflix_clean
GROUP BY type
ORDER BY count_items DESC;

-- Q2) Most common rating for Movies and TV Shows
WITH r AS (
  SELECT type, rating, COUNT(*) AS cnt,
         ROW_NUMBER() OVER (PARTITION BY type ORDER BY COUNT(*) DESC, rating) AS rn
  FROM netflix_clean
  WHERE rating IS NOT NULL AND TRIM(rating) <> ''
  GROUP BY type, rating
)
SELECT type, rating AS most_common_rating, cnt AS occurrences
FROM r
WHERE rn = 1;

-- 3) All movies released in 2020
SELECT title, release_year, rating, duration
FROM netflix_clean
WHERE type = 'Movie' AND release_year = 2020
ORDER BY title;

-- Q4) Top 5 countries with the most content
WITH countries AS (
  SELECT
    nc.show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(nc.country, ',', h.n), ',', -1)) AS country_single
  FROM netflix_clean nc
  JOIN helper_nums h
    ON h.n <= 1 + LENGTH(nc.country) - LENGTH(REPLACE(nc.country, ',', ''))
  WHERE nc.country IS NOT NULL AND nc.country <> ''
)
SELECT country_single AS country, COUNT(*) AS total_titles
FROM countries
GROUP BY country_single
ORDER BY total_titles DESC
LIMIT 5;

-- Q5) Longest movie (by minutes)
SELECT title, duration
FROM netflix_clean
WHERE type = 'Movie' AND duration_value IS NOT NULL
ORDER BY  duration DESC, title
LIMIT 1;

-- Q6) Content added in the last 5 years
SELECT title, type, date_added_dt
FROM netflix_clean
WHERE date_added_dt >= (CURRENT_DATE - INTERVAL 5 YEAR)
ORDER BY date_added_dt DESC, title;

-- Q7) All titles by director Rajiv Chilaka
SELECT title, type, director
FROM netflix_clean
WHERE director = 'Rajiv Chilaka'
ORDER BY type, title;

-- Q8) TV shows with more than 5 seasons
SELECT title, seasons
FROM netflix_clean
WHERE type = 'TV Show' AND seasons IS NOT NULL AND seasons > 5
ORDER BY seasons DESC, title;

-- Q9) Count content items in each genre (listed_in)
WITH genres AS (
  SELECT
    nc.show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(nc.listed_in, ',', h.n), ',', -1)) AS genre
  FROM netflix_clean nc
  JOIN helper_nums h
    ON h.n <= 1 + LENGTH(nc.listed_in) - LENGTH(REPLACE(nc.listed_in, ',', ''))
  WHERE nc.listed_in IS NOT NULL AND nc.listed_in <> ''
)
SELECT genre, COUNT(*) AS items
FROM genres
GROUP BY genre
ORDER BY items DESC, genre;

-- Q10) For each year, average monthly content additions in United States → return top 5 years
WITH countries AS (
  SELECT
    nc.show_id, nc.date_added_dt,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(nc.country, ',', h.n), ',', -1)) AS country_single
  FROM netflix_clean nc
  JOIN helper_nums h
    ON h.n <= 1 + LENGTH(nc.country) - LENGTH(REPLACE(nc.country, ',', ''))
  WHERE nc.country IS NOT NULL AND nc.country <> '' AND nc.date_added_dt IS NOT NULL
),
us AS (
  SELECT date_added_dt
  FROM countries
  WHERE country_single = 'United States'
),
by_month AS (
  SELECT YEAR(date_added_dt) AS yr, MONTH(date_added_dt) AS mo, COUNT(*) AS monthly_adds
  FROM us
  GROUP BY YEAR(date_added_dt), MONTH(date_added_dt)
),
avg_by_year AS (
  SELECT yr AS year, AVG(monthly_adds) AS avg_monthly_adds
  FROM by_month
  GROUP BY yr
)
SELECT year, ROUND(avg_monthly_adds, 2) AS avg_monthly_adds
FROM avg_by_year
ORDER BY avg_monthly_adds DESC
LIMIT 5;

-- Q11) All movies that are documentaries
SELECT title, listed_in
FROM netflix_clean
WHERE type = 'Movie'
  AND LOWER(listed_in) LIKE '%documentaries%'
ORDER BY title;

-- Q12) All content without a director
SELECT title, type
FROM netflix_clean
WHERE director IS NULL OR TRIM(director) = ''
ORDER BY type, title;

-- Q13) How many movies actor Salman Khan appeared in last 10 years
SELECT COUNT(*) AS movies_last_10y
FROM netflix_clean
WHERE type = 'Movie'
  AND release_year >= YEAR(CURRENT_DATE) - 9
  AND cast LIKE '%Salman Khan%';

-- Q14) Top 10 actors in number of movies produced in United States
WITH us_movies AS (
  SELECT nc.show_id, nc.cast
  FROM netflix_clean nc
  JOIN helper_nums h
    ON h.n <= 1 + LENGTH(nc.country) - LENGTH(REPLACE(nc.country, ',', ''))
  WHERE nc.type = 'Movie'
    AND TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(nc.country, ',', h.n), ',', -1)) = 'United States'
),
actors AS (
  SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(um.cast, ',', hn.n), ',', -1)) AS actor
  FROM us_movies um
  JOIN helper_nums hn
    ON hn.n <= 1 + LENGTH(um.cast) - LENGTH(REPLACE(um.cast, ',', ''))
  WHERE um.cast IS NOT NULL AND um.cast <> ''
)
SELECT actor, COUNT(*) AS movie_count
FROM actors
WHERE actor <> ''
GROUP BY actor
ORDER BY movie_count DESC, actor
LIMIT 10;

-- Q15) Categorize content by keywords 'kill' or 'violence' in description → count “Bad” vs “Good”
SELECT
  CASE
    WHEN description IS NOT NULL AND (
         LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%'
    ) THEN 'Bad'
    ELSE 'Good'
  END AS category,
  COUNT(*) AS items
FROM netflix_clean
GROUP BY category
ORDER BY items DESC;