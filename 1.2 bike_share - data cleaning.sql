-- DATA CLEANING
-- We have two most important information to check: 1. type of user and 2. duration of rides

-- type of user
-- Cheking what values are stored in column member_casual for type of user
SELECT DISTINCT member_casual 
FROM bike_share;

-- four types of users found: "casual", "casual;", "member" and "member;" -- probably some issue in the csv file... time to clean
UPDATE bike_share
SET member_casual='casual'
WHERE member_casual LIKE 'casual%';

UPDATE bike_share
SET member_casual='member'
WHERE member_casual LIKE 'member%';

-- let's check if the update worked
SELECT DISTINCT member_casual 
FROM bike_share; -- yes, now only "member" and "casual" found


-- duration of rides
-- Let's now check the second most important information in our data: the duration of the rides. This can be calculated by the difference of the ended_at and started_at columns
SELECT timestampdiff(second, started_at, ended_at) FROM bike_share WHERE timestampdiff(second, started_at, ended_at) = 0; -- several rides found
SELECT COUNT(DISTINCT ride_id) FROM bike_share WHERE timestampdiff(second, started_at, ended_at) = 0; -- 441 rides with duration zero. to be exclided from analysis

-- let's check if there are any outliers in the data by checking the max duration of a ride in minutes
SELECT 
	MAX(timestampdiff(minute, started_at, ended_at)) AS max_duration
FROM bike_share; -- the max durantion of a ride is 41.387 minutes. This is more than 28 days. 
-- Usualy users renting bikes from a bike share company don't rent the bike for more than 24 hours because of the cost. Let's count how many rides took longer than 24 hours.

SELECT COUNT(DISTINCT ride_id) AS count_duration_long
FROM bike_share 
WHERE timestampdiff(hour, started_at, ended_at) > 24; -- 1.974 rides took longer than a day. Let's check the top 100 durations and see where they start and where they end

SELECT 
	start_station_name,
    end_station_name,
    timestampdiff(day, started_at, ended_at) AS duration
FROM bike_share
ORDER BY duration DESC
LIMIT 100; -- out of the top 100 only one ride has the end_station. It's likely that for the others some issue happened and the end was not triggered. Let's continue to check to decide if all all rides with ended_station should be excluded

-- I'll check if other columns have empty values
SELECT * FROM bike_share WHERE start_station_name = '' OR end_station_name = ''; -- several results
SELECT COUNT(DISTINCT ride_id) FROM bike_share WHERE start_station_name = '' OR end_station_name = ''; -- 1.324.816 rides. This is a lot! Should I remove all or only the ones above 24 hours? Let's first check how many are above 24 hours.
SELECT COUNT(DISTINCT ride_id) FROM bike_share WHERE (start_station_name = '' OR end_station_name = '') AND timestampdiff(hour, started_at, ended_at) >= 24; -- 5.246 rides are above 24 hours
SELECT COUNT(DISTINCT ride_id) FROM bike_share WHERE (start_station_name = '' OR end_station_name = '') AND timestampdiff(hour, started_at, ended_at) < 24; -- 1.319.570 rides are below 24 hours. Let's check if rides without start or end can have low durations as well
SELECT *, 
	concat(
		timestampdiff(day, started_at, ended_at), ".",
        timestampdiff(hour, started_at, ended_at), ":",
		mod(timestampdiff(minute, started_at, ended_at),60)
	) as duration
FROM bike_share
WHERE (start_station_name = '' OR end_station_name = '') AND timestampdiff(minute, started_at, ended_at) >= 2
ORDER BY duration ASC; -- This shows that rides without start or end station can have reasonable duration, therefore I should not simply exclude all of them from the analysis
SELECT COUNT(DISTINCT ride_id) FROM bike_share WHERE timestampdiff(minute, started_at, ended_at) < 2 AND timestampdiff(minute, started_at, ended_at) > 0; -- 109.005 rides
SELECT COUNT(*) FROM bike_share WHERE ride_id = ''; -- zero rows. this is good!
SELECT COUNT(*) FROM bike_share WHERE rideable_type = ''; -- zero rows. this is good!
SELECT COUNT(*) FROM bike_share WHERE started_at IS NULL OR ended_at IS NULL; -- zero rows. this is good!
-- I will not mind about geographic coordinates for this analysis. And I already checked for member_casual column at the start.
-- Conclusion: There are rides with empty start or end station that still can contribute to the over all analysis. 
-- for this reason I will proceed excluding only rides with duration above 24 hours and below 2 minutes. 
-- 2 minutes was chosen as the bottom limit



-- based on the verifications performedabove, the data used in this case study should be the outcome of the query below. This completes the data cleaning process
SELECT *, 
	concat(
		-- timestampdiff(day, started_at, ended_at), ".", (all rides longer tha 24 hours removed)
        timestampdiff(hour, started_at, ended_at), ":",
		mod(timestampdiff(minute, started_at, ended_at),60), ":",
		mod(timestampdiff(second, started_at, ended_at),60)
	) as duration
FROM bike_share
WHERE timestampdiff(hour, started_at, ended_at) < 24 AND timestampdiff(minute, started_at, ended_at) > 2;

SELECT COUNT(DISTINCT ride_id) 
FROM bike_share
WHERE timestampdiff(hour, started_at, ended_at) < 24 AND timestampdiff(minute, started_at, ended_at) > 2; -- this is 5.372.876 rides. the data is now much more realible and we still have the majority of the data available to work with

SELECT(
	SELECT COUNT(DISTINCT ride_id) 
	FROM bike_share
	WHERE timestampdiff(hour, started_at, ended_at) < 24 AND timestampdiff(minute, started_at, ended_at) > 2)/
		(SELECT COUNT(DISTINCT ride_id) 
		FROM bike_share)*100; -- just out of curiosity, we are still using almost 92% of the initial number of rides in the csv files. Let's dive into the analysis!
