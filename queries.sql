--Chapter 2: Short and Simple subqueries 

-- Simple subquery
SELECT home_goal 
FROM match 
WHERE home_goal > (
	SELECT AVE(home_goal)
	FROM match); 
SELECT AVG(home_goal) FROM match; 

SELECT date, hometeam_id, awayteam_id, home_goal, away_goal
FROM match 
WHERE season = '2012/2013'
	AND home_goal > (SELECT AVG(home_goal)
					FROM match); 
					 
-- which teams are part of Poland's league?
SELECT 
	team_league_name,
	team_short_name AS abbr
FROM team 
WHERE 
	team_api_id IN 
	(SELECT hometeam_id 
	FROM match 
	WHERE country_id = 15722); 
	
-- Select the average of home + away goals, multiplied by 3
SELECT 
	3 * AVG(home_goal + away_goal)
FROM matches_2013_2014;	
SELECT 
	-- Select the date, home goals, and away goals scored
    date,
	home_goal,
	away_goal
FROM  matches_2013_2014

-- Filter for matches where total goals exceeds 3x the average
WHERE (home_goal + away_goal) > 
       (SELECT 3 * AVG(home_goal + away_goal)
        FROM matches_2013_2014); 
		
SELECT 
	-- Select the date, home goals, and away goals scored
    date,
	home_goal,
	away_goal
FROM  matches_2013_2014
-- Filter for matches where total goals exceeds 3x the average
WHERE (home_goal + away_goal) > 
       (SELECT 3 * AVG(home_goal + away_goal)
        FROM matches_2013_2014); 
		
SELECT
	-- Select the team long and short names
	team_long_name,
	team_short_name
FROM team
-- Filter for teams with 8 or more home goals
WHERE team_api_id IN
	  (SELECT hometeam_id 
       FROM match
       WHERE home_goal >= 8);

-- Subqueries in FROM 

SELECT team, home_avg
FROM (SELECT
	 	t.team_long_name AS team,
	 	AVG(m.home_goal) AS home_avg 
	 FROM match AS m 
	 LEFT JOIN team AS t 
	 ON m.hometean_id = t.team_api_id
	 WHERE season = '2011/2012'
	 GROUP BY team) AS subquery 
ORDER BY home_avg DESC 
LIMIT 3; 

SELECT 
	-- Select the country ID and match ID
	country_id, 
    id 
FROM match
-- Filter for matches with 10 or more goals in total
WHERE (home_goal + away_goal) >= 10; 

SELECT
	-- Select country name and the count match IDs
    c.name AS country_name,
    COUNT(sub.id) AS matches
FROM country AS c
-- Inner join the subquery onto country
-- Select the country id and match id columns
INNER JOIN (SELECT country_id, id 
            FROM match
            -- Filter the subquery by matches with 10+ goals
            WHERE (home_goal + away_goal) >= 10) AS sub
ON c.id = sub.country_id
GROUP BY country_name;

SELECT
	-- Select country name and the count match IDs
    c.name AS country_name,
    COUNT(sub.id) AS matches
FROM country AS c
-- Inner join the subquery onto country
-- Select the country id and match id columns
INNER JOIN (SELECT country_id, id 
            FROM match
            -- Filter the subquery by matches with 10+ goals
            WHERE (home_goal + away_goal) >= 10) AS sub
ON c.id = sub.country_id
GROUP BY country_name; 

--Subqueries in SELECT
	-- Calculate the total matches across all seasons
	SELECT COUNT(id) FROM match; 
	--Output: 12837
	
SELECT 
	season,
	COUNT(id) AS matches, 
	(SELECT COUNT(id) FROM match) AS total_matches
FROM match 
GROUP BY season; 

SELECT 
	date,
	(home_goal + away_goal) AS goals,
	(home_goal + away_goal) - 
		(SELECT AVG(home_goal + away_goal)
		FROM match 
		WHERE season = '2011/2012') AS diff
FROM match 
WHERE season = '2011/2012'; 

SELECT 
	l.name AS league,
    -- Select and round the league's total goals
    ROUND(AVG(m.home_goal + m.away_goal), 2) AS avg_goals,
    -- Select & round the average total goals for the season
    (SELECT ROUND(AVG(home_goal + away_goal), 2) 
     FROM match
     WHERE season = '2013/2014') AS overall_avg
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
-- Filter for the 2013/2014 season
WHERE season = '2013/2014'
GROUP BY l.name; 

SELECT
	-- Select the league name and average goals scored
	l.name AS league,
	ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
    -- Subtract the overall average from the league average
	ROUND(AVG(m.home_goal + m.away_goal) - 
		(SELECT AVG(home_goal + away_goal)
		 FROM match 
         WHERE season = '2013/2014'),2) AS diff
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
-- Only include 2013/2014 results
WHERE season = '2013/2014'
GROUP BY l.name;

SELECT 
	country_id, 
	ROUND(AVG(matches.home_goal +matchesaway_goal),2) AS avg_goals,
	(SELECT ROUND(AVG(home_goal + away_goal),2)
	 FROM match WHERE season = '2013/2014' AS overall_avg
FROM (SELECT 
	 id,
	 home_goal, 
	 away_goal, 
	 season
	 FROM match 
	 WHERE home_goal > 5) AS matches 
WHERE matches.season = '2013/2014' 
	 AND (AVG(matcches.home_goal + matches.away_goal) > 
		 (SELECT AVG(home_goal + away_goal) 
		 FROM match WHERE season = '2013/2014')
GROUP BY country_id; 

	/* Making additional notes & summary comments */
		  
SELECT 
	-- Select the stage and average goals for each stage
	m.stage,
    ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
    -- Select the average overall goals for the 2012/2013 season
    ROUND((SELECT AVG(home_goal + away_goal) 
           FROM match 
           WHERE season = '2012/2013'),2) AS overall
FROM match AS m
-- Filter for the 2012/2013 season
WHERE season = '2012/2013'
-- Group by stage
GROUP BY stage;
		  
SELECT 
	-- Select the stage and average goals from the subquery
	stage,
	ROUND(avg_goals,2) AS avg_goals
FROM 
	-- Select the stage and average goals in 2012/2013
	(SELECT
		 stage,
         AVG(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season = '2012/2013'
	 GROUP BY stage) AS s
WHERE 
	-- Filter the main query using the subquery
	s.avg_goals > (SELECT AVG(home_goal + away_goal) 
                    FROM match WHERE season = '2012/2013'); 

SELECT 
	-- Select the stage and average goals from s
	stage,
    ROUND(avg_goals,2) AS avg_goal,
    -- Select the overall average for 2012/2013
    (SELECT AVG(home_goal + away_goal) FROM match WHERE season = '2012/2013') AS overall_avg
FROM 
	-- Select the stage and average goals in 2012/2013 from match
	(SELECT
		 stage,
         AVG(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season = '2012/2013'
	 GROUP BY stage) AS s
WHERE 
	-- Filter the main query using the subquery
	s.avg_goals > (SELECT AVG(home_goal + away_goal) 
                    FROM match WHERE season = '2012/2013');
