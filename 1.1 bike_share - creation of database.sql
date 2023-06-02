-- CREATION OF DATABASE FOR CASE STUDY
CREATE DATABASE case_study_1;
USE case_study_1;

CREATE TABLE bike_share
(
	ride_id VARCHAR(50),
    rideable_type varchar(50),
    started_at DATETIME,
    ended_at DATETIME,
    start_station_name VARCHAR(255),
    start_station_id VARCHAR(50),
    end_station_name VARCHAR(255),
    end_station_id VARCHAR(50),
    start_lat VARCHAR(50), -- used as string. no aggreation is performed on geographic coordinates
    start_lng VARCHAR(50),
    end_lat VARCHAR(50),
    end_lng VARCHAR(50),
    member_casual VARCHAR(50)
);

-- checking the new table
SELECT * FROM bike_share_test;
DESC bike_share_test;

-- adding data from the CSV files downloaded from: https://divvy-tripdata.s3.amazonaws.com/index.html
-- license under:  https://ride.divvybikes.com/data-license-agreement
-- time spam: May 2022 to April 2023

-- add 1st csv file 202205
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202205-divvy-tripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add 2nd csv file 202206
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202206-divvy-tripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add 3rd csv file 202207
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202207-divvy-tripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add 4th csv file 202208
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202208-divvy-tripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add 5th csv file 202209
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202209-divvy-publictripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add 6th csv file 202210
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202210-divvy-tripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add 7th csv file 202211
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202211-divvy-tripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add 8th csv file
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202212-divvy-tripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add 9th csv file
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202301-divvy-tripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add 10th csv file
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202302-divvy-tripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add 11th csv file
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202303-divvy-tripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add 12th csv file
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/202304-divvy-tripdata.csv'
INTO TABLE bike_share
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) 
FROM bike_share; -- 5.859.061 rows added!! It worked :)

-- first glance at the data
SELECT * 
FROM bike_share;