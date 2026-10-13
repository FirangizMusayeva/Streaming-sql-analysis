-- mysql_load.sql : load the CSV files into MySQL (run AFTER 01_schema.sql)
-- You may need:  SET GLOBAL local_infile = 1;  and to start the client with --local-infile=1
-- Adjust the paths below to where you saved the project.

LOAD DATA LOCAL INFILE 'data/titles.csv' INTO TABLE titles
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(title_id, title, type, genre, @country, release_year, @rating, duration_min, date_added)
SET country = NULLIF(@country, ''), rating = NULLIF(@rating, '');

LOAD DATA LOCAL INFILE 'data/users.csv' INTO TABLE users
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'data/watch_events.csv' INTO TABLE watch_events
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
