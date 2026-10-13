-- 02_data_quality_and_cleaning.sql
-- Step 1: inspect problems. Step 2: build a cleaned view (raw tables are never modified).

-- Q: Missing values in titles
SELECT
    SUM(CASE WHEN country IS NULL OR TRIM(country) = '' THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN rating  IS NULL OR TRIM(rating)  = '' THEN 1 ELSE 0 END) AS missing_rating
FROM titles;

-- Q: Genre spelling variants (same genre written with different case / spaces)
SELECT genre, COUNT(*) AS rows_count
FROM titles
GROUP BY genre
ORDER BY LOWER(TRIM(genre)), genre;

-- Q: Duplicate titles (same title text + release year)
SELECT LOWER(TRIM(title)) AS title_key, release_year, COUNT(*) AS copies
FROM titles
GROUP BY LOWER(TRIM(title)), release_year
HAVING COUNT(*) > 1
ORDER BY copies DESC, title_key
LIMIT 10;

-- Cleaned view: trimmed/lower-cased genre, NULL for blanks, duplicates removed (lowest id kept)
DROP VIEW IF EXISTS titles_clean;
CREATE VIEW titles_clean AS
SELECT title_id, title, type, genre_key AS genre, country, release_year, rating, duration_min, date_added
FROM (
    SELECT
        title_id,
        title,
        type,
        LOWER(TRIM(genre)) AS genre_key,
        CASE WHEN TRIM(country) = '' THEN NULL ELSE country END AS country,
        release_year,
        CASE WHEN TRIM(rating) = '' THEN NULL ELSE rating END AS rating,
        duration_min,
        date_added,
        ROW_NUMBER() OVER (
            PARTITION BY LOWER(TRIM(title)), release_year
            ORDER BY title_id
        ) AS rn
    FROM titles
) t
WHERE rn = 1;

-- Q: Check after cleaning - rows before vs after
SELECT (SELECT COUNT(*) FROM titles) AS rows_raw,
       (SELECT COUNT(*) FROM titles_clean) AS rows_clean;
