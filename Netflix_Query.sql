
/* =========================================================
   NETFLIX ANALYTICS PROJECT
   Database: NetflixAnalytics
   Table: NetflixTitles
   Tool: SQL Server
   ========================================================= */


/* =========================================================
   DATABASE SETUP
   ========================================================= */

CREATE DATABASE NetflixAnalytics;
GO

USE NetflixAnalytics;
GO


/* =========================================================
   1. VIEW SAMPLE DATA
   ========================================================= */

SELECT TOP 10 *
FROM NetflixTitles;

/* =========================================================
   Q1. How many unique titles are in the dataset?
   Dashboard: Total Titles KPI
   ========================================================= */

SELECT
    COUNT(DISTINCT show_id) AS TotalTitles
FROM dbo.NetflixTitles;


/* =========================================================
   Q2. How many Movies and TV Shows are there?
   Dashboard: Movies and TV Shows KPI cards
   ========================================================= */

SELECT
    type,
    COUNT(DISTINCT show_id) AS TotalTitles
FROM dbo.NetflixTitles
GROUP BY type
ORDER BY TotalTitles DESC;


/* =========================================================
   Q3. What percentage of titles are Movies and TV Shows?
   Dashboard: Movie Share KPI
   ========================================================= */

SELECT
    type,
    COUNT(DISTINCT show_id) AS TotalTitles,
    CAST(
        100.0 * COUNT(DISTINCT show_id)
        / NULLIF(
            (SELECT COUNT(DISTINCT show_id)
             FROM dbo.NetflixTitles), 0
        )
        AS DECIMAL(5,2)
    ) AS Percentage
FROM dbo.NetflixTitles
GROUP BY type
ORDER BY TotalTitles DESC;


/* =========================================================
   Q4. What are the five most common content ratings?
   Dashboard: Top 5 Content Ratings by Title Count
   ========================================================= */

SELECT TOP 5
    rating,
    COUNT(DISTINCT show_id) AS TotalTitles
FROM dbo.NetflixTitles
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY TotalTitles DESC, rating ASC;


/* =========================================================
   Q5. How many titles were released in each year?
   Dashboard: Titles Released by Year
   ========================================================= */

SELECT
    release_year,
    COUNT(DISTINCT show_id) AS TotalTitles
FROM dbo.NetflixTitles
WHERE release_year IS NOT NULL
GROUP BY release_year
ORDER BY release_year ASC;


/* =========================================================
   Q6. How many titles were added to Netflix each year?
   Dashboard: Titles Added Over Time
   date_added format: DD-MM-YYYY
   ========================================================= */

WITH ParsedDates AS (
    SELECT
        show_id,
        TRY_CONVERT(date, date_added, 105) AS AddedDate
    FROM dbo.NetflixTitles
)
SELECT
    YEAR(AddedDate) AS AddedYear,
    COUNT(DISTINCT show_id) AS TotalTitles
FROM ParsedDates
WHERE AddedDate IS NOT NULL
GROUP BY YEAR(AddedDate)
ORDER BY AddedYear ASC;


/* =========================================================
   Q7. Which countries are associated with the most titles?
   Dashboard: Netflix Content by Country map
   Each title can belong to multiple countries.
   ========================================================= */

SELECT
    LTRIM(RTRIM(country_split.value)) AS Country,
    COUNT(DISTINCT nt.show_id) AS TotalTitles
FROM dbo.NetflixTitles AS nt
CROSS APPLY STRING_SPLIT(nt.country, ',') AS country_split
WHERE NULLIF(LTRIM(RTRIM(country_split.value)), '') IS NOT NULL
GROUP BY LTRIM(RTRIM(country_split.value))
ORDER BY TotalTitles DESC;


/* =========================================================
   Q8. How many Movies exist at each duration in minutes?
   Dashboard: Movie Duration Distribution
   ========================================================= */

WITH MovieDurations AS (
    SELECT
        show_id,
        TRY_CONVERT(
            int,
            LEFT(duration, CHARINDEX(' ', duration + ' ') - 1)
        ) AS DurationMinutes
    FROM dbo.NetflixTitles
    WHERE type = 'Movie'
      AND duration LIKE '%min%'
)
SELECT
    DurationMinutes,
    COUNT(DISTINCT show_id) AS TotalMovies
FROM MovieDurations
WHERE DurationMinutes IS NOT NULL
GROUP BY DurationMinutes
ORDER BY DurationMinutes ASC;


/* =========================================================
   Q9. How many TV Shows have each number of seasons?
   Dashboard: TV Shows by Number of Seasons
   ========================================================= */

WITH TVSeasons AS (
    SELECT
        show_id,
        TRY_CONVERT(
            int,
            LEFT(duration, CHARINDEX(' ', duration + ' ') - 1)
        ) AS Seasons
    FROM dbo.NetflixTitles
    WHERE type = 'TV Show'
      AND duration LIKE '%Season%'
)
SELECT
    Seasons,
    COUNT(DISTINCT show_id) AS TotalShows
FROM TVSeasons
WHERE Seasons IS NOT NULL
GROUP BY Seasons
ORDER BY Seasons ASC;


/* =========================================================
   Q10. How are content ratings distributed between Movies
        and TV Shows?
   Dashboard: Content Ratings by Type
   ========================================================= */

SELECT
    type,
    rating,
    COUNT(DISTINCT show_id) AS TotalTitles
FROM dbo.NetflixTitles
WHERE rating IS NOT NULL
GROUP BY type, rating
ORDER BY rating ASC, type ASC;

