-- DATA ANALYSIS
-- At the end of this document you find a summary of the findings related to the casual users

-- I'll start by creating a temporary table with the result of our data cleaning process
CREATE VIEW bike_share_clean AS
SELECT *, 
	concat(
		-- timestampdiff(day, started_at, ended_at), ".", (all rides longer tha 24 hours removed)
        timestampdiff(hour, started_at, ended_at), ":",
		mod(timestampdiff(minute, started_at, ended_at),60), ":",
		mod(timestampdiff(second, started_at, ended_at),60)
	) as duration
FROM bike_share
WHERE timestampdiff(hour, started_at, ended_at) < 24 AND timestampdiff(minute, started_at, ended_at) > 2;

-- analysis around type of user
-- let's start by checking the number of rides per user type: member vs casual 
SELECT 
	member_casual, 
	COUNT(DISTINCT ride_id) AS count
FROM bike_share_clean
GROUP BY member_casual; -- members have a higher number of rides over the last 12 months. 2.215.974 casual and 3.156.902 member

-- now with the percentage added
SELECT 
	member_casual, 
	COUNT(DISTINCT ride_id) AS count,
    (COUNT(DISTINCT ride_id) / (SELECT COUNT(DISTINCT ride_id) FROM bike_share_clean) *100) AS percentage
FROM bike_share_clean
GROUP BY member_casual; -- 41.2% casual and 58.8% member

-- let's see the average duration of rides per user type
SELECT 
	member_casual,
	AVG(timestampdiff(minute, started_at, ended_at)) as avg_duration
FROM bike_share_clean
GROUP BY member_casual; -- casual members rider for longer periods of time in average: result is 22,0 minutes casual vs 12,8 minutes member

-- let's see now the number of rides over the months and seasons
-- number of rides and percentage over the months
SELECT 
	MONTHNAME(started_at), 
	COUNT(DISTINCT ride_id) AS count,
    COUNT(DISTINCT ride_id)/(SELECT COUNT(DISTINCT ride_id) from bike_share_clean)*100 AS percentage
FROM bike_share_clean
GROUP BY MONTHNAME(started_at)
ORDER BY COUNT(DISTINCT ride_id) DESC; -- July is the month with highest number of rides at 767.766 (14,3%) followed by August (13,6%) and June (13,4%). December has the lowest number of rides at 161.562 (3,0%). January at 3,10% and February at 3,11%. 
-- clearly summer has the highest number of rides and winter the lowest, which makes sense for an outdoor activity such as biking

-- let's check the percentages by season
SELECT 
	CASE
		WHEN MONTHNAME(started_at) = 'June' OR MONTHNAME(started_at) = 'July' OR MONTHNAME(started_at) = 'August' THEN 'Summer'
		WHEN MONTHNAME(started_at) = 'December' OR MONTHNAME(started_at) = 'January' OR MONTHNAME(started_at) = 'February' THEN 'Winter'
		WHEN MONTHNAME(started_at) = 'March' OR MONTHNAME(started_at) = 'April' OR MONTHNAME(started_at) = 'May' THEN 'Spring'
		WHEN MONTHNAME(started_at) = 'September' OR MONTHNAME(started_at) = 'October' OR MONTHNAME(started_at) = 'November' THEN 'Fall'
	END AS season,
	COUNT(DISTINCT ride_id) AS count,
    COUNT(DISTINCT ride_id)/(SELECT COUNT(DISTINCT ride_id) from bike_share_clean)*100 AS percentage
FROM bike_share_clean
GROUP BY season
ORDER BY COUNT(DISTINCT ride_id) DESC; -- Summer at 41,2%, Fall at 27,2%, Spring at 22,3% and Winter at 9,22%

-- let's confirm if the same is true when we split the type of user: casual vs member
SELECT 
	member_casual,
    CASE
		WHEN MONTHNAME(started_at) = 'June' OR MONTHNAME(started_at) = 'July' OR MONTHNAME(started_at) = 'August' THEN 'Summer'
		WHEN MONTHNAME(started_at) = 'December' OR MONTHNAME(started_at) = 'January' OR MONTHNAME(started_at) = 'February' THEN 'Winter'
		WHEN MONTHNAME(started_at) = 'March' OR MONTHNAME(started_at) = 'April' OR MONTHNAME(started_at) = 'May' THEN 'Spring'
		WHEN MONTHNAME(started_at) = 'September' OR MONTHNAME(started_at) = 'October' OR MONTHNAME(started_at) = 'November' THEN 'Fall'
	END AS season,
	COUNT(DISTINCT ride_id) AS count,
    COUNT(DISTINCT ride_id)/(SELECT COUNT(DISTINCT ride_id) from bike_share_clean)*100 AS percentage
FROM bike_share_clean
GROUP BY member_casual, season
ORDER BY COUNT(DISTINCT ride_id) DESC; -- yes, highest percentages in Summer and lowest in Winter. Important highlight is that casual rides in winter are only 2,2%, which is very low

-- let's now check if there is also a preference for weekend or week day
-- number of rides split by days of the week
SELECT 
	DAYNAME(started_at) AS day, 
	COUNT(DISTINCT ride_id) AS count,
    COUNT(DISTINCT ride_id)/(SELECT COUNT(DISTINCT ride_id) from bike_share_clean)*100 AS percentage
FROM bike_share_clean
GROUP BY DAYNAME(started_at)
ORDER BY COUNT(DISTINCT ride_id) DESC; -- the percentages don't differ much between the days. It ranges from 12,9% on Monday to 15,9% on Saturday. Thrusday comes second, Friday is third, then Wednesday, Tuesday and Sunday.
-- Even though Saturday has the highest percentage we cannot say there is a preferece for the weekend, as Sunday is second-to-last.

-- let's make the split also for type of user. First members
SELECT 
	DAYNAME(started_at) AS day, 
	COUNT(DISTINCT ride_id) AS count,
    COUNT(DISTINCT ride_id)/(SELECT COUNT(DISTINCT ride_id) from bike_share_clean WHERE member_casual = 'member')*100 AS percentage
FROM bike_share_clean
WHERE member_casual = 'member'
GROUP BY DAYNAME(started_at)
ORDER BY COUNT(DISTINCT ride_id) DESC; -- Thu (16,0%) > Wed > Tue > Fri > Mon > Sat > Sun (11,5%)

-- now casual riders
SELECT 
	DAYNAME(started_at) AS day, 
	COUNT(DISTINCT ride_id) AS count,
    COUNT(DISTINCT ride_id)/(SELECT COUNT(DISTINCT ride_id) from bike_share_clean WHERE member_casual = 'casual')*100 AS percentage
FROM bike_share_clean
WHERE member_casual = 'casual'
GROUP BY DAYNAME(started_at)
ORDER BY COUNT(DISTINCT ride_id) DESC; -- Sat (19,4%) > Sun > Fri > Thu > Wed > Mon > Tue (11,5%)
-- conclusion: there is now a clear split between type of user and preferece for days of the week. 
-- members use have more rides during week days while casual riders have the highest volume during the weekend

-- so far we have identified that casual users perfer summer and the weekends. As the goal is to convert casual users into members, let's also see in which locations they start their rides so that we can target marketing
-- top 5 locations in summer for casual
SELECT 
	start_station_name,
    COUNT(DISTINCT ride_id) AS count
FROM bike_share_clean
WHERE 
	start_station_name != ''
    AND (MONTHNAME(started_at) = 'June' 
    OR MONTHNAME(started_at) = 'July' 
    OR MONTHNAME(started_at) = 'August')
	AND member_casual = 'casual'
GROUP BY start_station_name
ORDER BY COUNT(DISTINCT ride_id) DESC
LIMIT 5; -- 'Streeter Dr & Grand Ave' > 'DuSable Lake Shore Dr & Monroe St' > 'DuSable Lake Shore Dr & North Blvd' > 'Michigan Ave & Oak St' > 'Millennium Park'

-- now the top 5 locations on weekends for casual
SELECT 
	start_station_name,
    COUNT(DISTINCT ride_id) AS count
FROM bike_share_clean
WHERE 
	start_station_name != ''
    AND (DAYNAME(started_at) = 'Saturday' 
    OR MONTHNAME(started_at) = 'Sunday')
    AND member_casual = 'casual'
GROUP BY start_station_name
ORDER BY COUNT(DISTINCT ride_id) DESC
LIMIT 5; -- 'Streeter Dr & Grand Ave' > 'DuSable Lake Shore Dr & Monroe St' > 'Michigan Ave & Oak St' > 'Millennium Park' > 'DuSable Lake Shore Dr & North Blvd' 
-- same top 5 but slightly different order

-- now let's check what kind of bike the casual users use the most
SELECT 
	rideable_type,
    COUNT(DISTINCT ride_id) AS count,
    COUNT(DISTINCT ride_id)/(SELECT COUNT(DISTINCT ride_id) from bike_share_clean WHERE member_casual = 'casual')*100 AS percentage
FROM bike_share_clean
WHERE member_casual = 'casual'
GROUP BY rideable_type
ORDER BY count DESC; -- electric bikes = 54,1% > classic bikes = 38,4% > docked bikes = 7,46%

-- the last analysis I'll check is for the time of day that each type of user uses the bikes
-- time of day all users
SELECT 
	CASE
		WHEN TIME(started_at) BETWEEN '00:00:00' AND '05:00:00' THEN 'Night'
        WHEN TIME(started_at) BETWEEN '05:00:01' AND '12:00:00' THEN 'Morning'
		WHEN TIME(started_at) BETWEEN '12:00:01' AND '18:00:00' THEN 'Afternoon'
		WHEN TIME(started_at) BETWEEN '18:00:01' AND '22:00:00' THEN 'Evening'
        WHEN TIME(started_at) BETWEEN '22:00:01' AND '23:59:59' THEN 'Night'
	END AS time_of_day,
	COUNT(DISTINCT ride_id) AS count,
    COUNT(DISTINCT ride_id)/(SELECT COUNT(DISTINCT ride_id) from bike_share_clean)*100 AS percentage
FROM bike_share_clean
GROUP BY time_of_day
ORDER BY COUNT(DISTINCT ride_id) DESC; -- Afternoon 43,8% > Morning 24,5% > Evening 23,1% > Night 8,57%

-- time of day only for members
SELECT 
	CASE
		WHEN TIME(started_at) BETWEEN '00:00:00' AND '05:00:00' THEN 'Night'
        WHEN TIME(started_at) BETWEEN '05:00:01' AND '12:00:00' THEN 'Morning'
		WHEN TIME(started_at) BETWEEN '12:00:01' AND '18:00:00' THEN 'Afternoon'
		WHEN TIME(started_at) BETWEEN '18:00:01' AND '22:00:00' THEN 'Evening'
        WHEN TIME(started_at) BETWEEN '22:00:01' AND '23:59:59' THEN 'Night'
	END AS time_of_day,
	COUNT(DISTINCT ride_id) AS count,
    COUNT(DISTINCT ride_id)/(SELECT COUNT(DISTINCT ride_id) FROM bike_share_clean WHERE member_casual = 'member')*100 AS percentage
FROM bike_share_clean
WHERE member_casual = 'member'
GROUP BY time_of_day
ORDER BY COUNT(DISTINCT ride_id) DESC; -- Afternoon 42,7% > Morning 28,0% > Evening 22,5% > Night 6,77% - very close to the overall numbers

-- time of day only for casual users
SELECT 
	CASE
		WHEN TIME(started_at) BETWEEN '00:00:00' AND '05:00:00' THEN 'Night'
        WHEN TIME(started_at) BETWEEN '05:00:01' AND '12:00:00' THEN 'Morning'
		WHEN TIME(started_at) BETWEEN '12:00:01' AND '18:00:00' THEN 'Afternoon'
		WHEN TIME(started_at) BETWEEN '18:00:01' AND '22:00:00' THEN 'Evening'
        WHEN TIME(started_at) BETWEEN '22:00:01' AND '23:59:59' THEN 'Night'
	END AS time_of_day,
	COUNT(DISTINCT ride_id) AS count,
    COUNT(DISTINCT ride_id)/(SELECT COUNT(DISTINCT ride_id) FROM bike_share_clean WHERE member_casual = 'casual')*100 AS percentage
FROM bike_share_clean
WHERE member_casual = 'casual'
GROUP BY time_of_day
ORDER BY COUNT(DISTINCT ride_id) DESC; -- Afternoon 45,4% > Morning 24,0% > Evening 19,5% > Night 11,1% - a slight increase during the night coming from the reduction of the other times of day

-- Summary:
-- Casual users make up for 41.2% of all rides
-- In average they ride for 22,0 minutes
-- They ride most during Summer and in Winter it's only around 2% of the total rides
-- More than 50% of their rides happen from Friday to Sunday
-- The afternoon is when most rides from casual users take place coming close to 50%. Then the morning, then evening and last is night.
-- Interesting is that the number of rides during the night from casual users are almost double the number of rides from members in this time of day
-- And the top 5 stations where they start their ride are Streeter Dr & Grand Ave, DuSable Lake Shore Dr & Monroe St, DuSable Lake Shore Dr & North Blvd, Michigan Ave & Oak St and Millennium Park
-- When it comes to the type of bikes they prefer, we can see that eletric bikes were used in more than half of their rides, follow by classic and last is docked with less than 10%
