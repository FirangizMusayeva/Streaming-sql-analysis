-- 03_analysis.sql : business questions answered with SQL
-- Each block starts with "-- Q:" (used by run_sqlite.py to label the results).

-- Q: 1. Catalog size by type and genre
SELECT type, genre, COUNT(*) AS titles_count
FROM titles_clean
GROUP BY type, genre
ORDER BY type, titles_count DESC;

-- Q: 2. Which genres get the most watch time? (hours, share of total)
SELECT
    t.genre,
    ROUND(SUM(e.minutes_watched) / 60.0, 1) AS watch_hours,
    ROUND(100.0 * SUM(e.minutes_watched) / SUM(SUM(e.minutes_watched)) OVER (), 1) AS pct_of_total
FROM watch_events e
JOIN titles_clean t ON t.title_id = e.title_id
GROUP BY t.genre
ORDER BY watch_hours DESC;

-- Q: 3. Monthly active users and watch hours (2025)
SELECT
    SUBSTR(watch_date, 1, 7) AS month,
    COUNT(DISTINCT user_id) AS active_users,
    ROUND(SUM(minutes_watched) / 60.0, 1) AS watch_hours
FROM watch_events
GROUP BY SUBSTR(watch_date, 1, 7)
ORDER BY month;

-- Q: 4. Running total of watch hours by month (window function)
WITH monthly AS (
    SELECT SUBSTR(watch_date, 1, 7) AS month,
           SUM(minutes_watched) / 60.0 AS hours
    FROM watch_events
    GROUP BY SUBSTR(watch_date, 1, 7)
)
SELECT month,
       ROUND(hours, 1) AS hours,
       ROUND(SUM(hours) OVER (ORDER BY month), 1) AS running_total_hours
FROM monthly
ORDER BY month;

-- Q: 5. Completion rate by genre (genres with at least 100 viewing events)
SELECT
    t.genre,
    COUNT(*) AS events,
    ROUND(100.0 * SUM(e.completed) / COUNT(*), 1) AS completion_rate_pct
FROM watch_events e
JOIN titles_clean t ON t.title_id = e.title_id
GROUP BY t.genre
HAVING COUNT(*) >= 100
ORDER BY completion_rate_pct DESC;

-- Q: 6. Top 3 titles per genre by watch time (RANK window function)
WITH title_time AS (
    SELECT t.genre, t.title, t.release_year,
           SUM(e.minutes_watched) AS total_minutes
    FROM watch_events e
    JOIN titles_clean t ON t.title_id = e.title_id
    GROUP BY t.genre, t.title, t.release_year
),
ranked AS (
    SELECT *, RANK() OVER (PARTITION BY genre ORDER BY total_minutes DESC) AS rnk
    FROM title_time
)
SELECT genre, rnk, title, release_year, total_minutes
FROM ranked
WHERE rnk <= 3
ORDER BY genre, rnk;

-- Q: 7. Average watch time per user by subscription plan
WITH per_user AS (
    SELECT u.user_id, u.plan, COALESCE(SUM(e.minutes_watched), 0) AS minutes
    FROM users u
    LEFT JOIN watch_events e ON e.user_id = u.user_id
    GROUP BY u.user_id, u.plan
)
SELECT plan,
       COUNT(*) AS users,
       ROUND(AVG(minutes) / 60.0, 1) AS avg_hours_per_user
FROM per_user
GROUP BY plan
ORDER BY avg_hours_per_user DESC;

-- Q: 8. How many users were active in 1, 2, 3 ... distinct months?
WITH user_months AS (
    SELECT user_id, COUNT(DISTINCT SUBSTR(watch_date, 1, 7)) AS active_months
    FROM watch_events
    GROUP BY user_id
)
SELECT active_months, COUNT(*) AS users
FROM user_months
GROUP BY active_months
ORDER BY active_months;

-- Q: 9. Watch hours per active user by country
SELECT
    u.country,
    COUNT(DISTINCT e.user_id) AS active_users,
    ROUND(SUM(e.minutes_watched) / 60.0, 1) AS watch_hours,
    ROUND(SUM(e.minutes_watched) / 60.0 / COUNT(DISTINCT e.user_id), 1) AS hours_per_active_user
FROM watch_events e
JOIN users u ON u.user_id = e.user_id
GROUP BY u.country
ORDER BY hours_per_active_user DESC;
