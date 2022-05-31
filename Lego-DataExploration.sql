/*
Lego data explorations for further visualizations. 
Utilizing Aggregate Functions, Converting Data Types, Join, Windows Functions, CTE's.
*/

-- Creating view 

CREATE VIEW AnalyticsMain AS

SELECT 
	s.set_num, s.name AS set_name, s.year, s.theme_id, CAST(s.num_parts AS numeric) AS num_parts, t.name AS theme_name, t.parent_id, p.name AS parent_theme_name
, CASE 
	WHEN s.year BETWEEN 1901 AND 2000 THEN '20th_Century'
	WHEN s.year BETWEEN 2001 AND 2100 THEN '21st_Century'
END
AS Century
FROM Rebrickable..sets s
LEFT JOIN Rebrickable..themes t
	ON s.theme_id = t.id
LEFT JOIN Rebrickable..themes p
	ON t.parent_id= p.id

-- Total Number of Parts per Theme
-- SELECT * FROM Rebrickable..AnalyticsMain

SELECT theme_name, SUM(num_parts) AS total_num_parts
FROM Rebrickable..AnalyticsMain
--WHERE parent_theme_name IS not null
GROUP BY theme_name
ORDER BY 2 DESC

-- Total Number of Parts per Year

SELECT year, SUM(num_parts) AS total_num_parts
FROM Rebrickable..AnalyticsMain
--WHERE parent_theme_name IS not null
GROUP BY year
ORDER BY 2 DESC

-- Number of Sets Created per Century

SELECT century, COUNT(set_num) AS total_set_num
FROM Rebrickable..AnalyticsMain
--WHERE parent_theme_name IS not null
GROUP BY century

-- Percentage of Sets Released in the 21st Century that were X Themed

WITH percentage_x_themed AS
(
	SELECT century, theme_name, COUNT(set_num) AS total_set_num
	FROM Rebrickable..AnalyticsMain
	WHERE century = '21st_Century'
	GROUP BY century, theme_name
)
SELECT SUM(total_set_num) AS set_sum, SUM(percentage_x_themed) AS percentage
FROM
(
	SELECT 
			century, theme_name, total_set_num, SUM(total_set_num) OVER () AS total, CAST(1.00 * total_set_num/SUM(total_set_num) OVER () AS decimal(5,4))*100 AS percentage_x_themed
	FROM percentage_x_themed
) m
WHERE theme_name LIKE '%trains%' 

-- The Most Popular Theme by Year in Terms of Sers Released in the 21st Century

SELECT year, theme_name, total_set_num
FROM
(
	SELECT 
			year, theme_name, COUNT(set_num) AS total_set_num, ROW_NUMBER () OVER (PARTITION BY year ORDER BY COUNT(set_num) DESC) rn
	FROM Rebrickable..AnalyticsMain
	WHERE century = '21st_Century' 
		--AND parent_theme_name IS not null
	GROUP BY year, theme_name
) m
WHERE rn = 1
ORDER BY year DESC