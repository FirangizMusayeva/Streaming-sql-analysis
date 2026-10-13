-- 01_schema.sql : tables for the streaming catalog project
-- Works in MySQL 8+ and SQLite 3.25+ (window functions required later).

DROP TABLE IF EXISTS watch_events;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS titles;

CREATE TABLE titles (
    title_id      INTEGER PRIMARY KEY,
    title         VARCHAR(100),
    type          VARCHAR(10),
    genre         VARCHAR(30),
    country       VARCHAR(30),
    release_year  INTEGER,
    rating        VARCHAR(10),
    duration_min  INTEGER,
    date_added    DATE
);

CREATE TABLE users (
    user_id      INTEGER PRIMARY KEY,
    signup_date  DATE,
    country      VARCHAR(30),
    plan         VARCHAR(20)
);

CREATE TABLE watch_events (
    event_id         INTEGER PRIMARY KEY,
    user_id          INTEGER,
    title_id         INTEGER,
    watch_date       DATE,
    minutes_watched  INTEGER,
    completed        INTEGER,
    FOREIGN KEY (user_id)  REFERENCES users(user_id),
    FOREIGN KEY (title_id) REFERENCES titles(title_id)
);
