--EDA
SELECT * FROM spotify;
SELECT DISTINCT artist FROM spotify;
SELECT DISTINCT album FROM spotify;
SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;
SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

-- ---------------------------------------------
--Data analysis - Easy category
-- ---------------------------------------------

-- Q1. Retreive the names of all track that have more than 1 billion streams.
SELECT 
	track,
	stream
FROM spotify
WHERE stream > 1000000000
ORDER BY stream DESC;

-- Q2. List all albums along with their respective artists.
SELECT
	DISTINCT album,
	artist
FROM spotify
ORDER BY album;

-- Q3. Get the total number of comments for tracks licenced = True.
SELECT SUM(comments) AS total_comments
FROM spotify
WHERE licensed IS TRUE;

-- Q4. Find all tracks that belong to the album type single.
SELECT
	track,
	album_type
FROM spotify
WHERE album_type ILIKE 'single'
ORDER BY track;

-- Q5. Count the total number of tracks by each artist.
SELECT
	artist,
	COUNT(track) AS Total_tracks
FROM spotify
GROUP BY artist
ORDER BY Total_tracks;

-- ---------------------------------------------
--Data analysis - Easy category
-- ---------------------------------------------

-- Q6. Calculate the average danceability of tracks in each album.
SELECT
	album,
	AVG(danceability) AS Avg_danceability
FROM spotify
GROUP BY album
ORDER BY Avg_danceability DESC;
	
-- Q7. Find the top 5 tracks with the highest energy values.
SELECT
	DISTINCT track,
	energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;

-- Q8. List all tracks along with their views and likes where official_video = True
SELECT
	track,
	views,
	likes
FROM spotify
WHERE official_video IS True;

-- Q9. For each album, calculate the total views of all associated tracks.
SELECT
	album,
	SUM(views) AS Total_views
FROM spotify
GROUP BY album
ORDER BY Total_views DESC;

-- Q10. Retreive the track names that have been streamed on spotify more than youtube.
SELECT * FROM 
(SELECT
	track,
	COALESCE(SUM((CASE WHEN most_played_on ILIKE 'Spotify' THEN stream END)),0) AS stream_spotify,
	COALESCE(SUM((CASE WHEN most_played_on ILIKE 'Youtube' THEN stream END)),0) AS stream_youtube
	--most_played_on
FROM spotify
GROUP BY track
) AS t1
WHERE stream_spotify > stream_youtube
	AND stream_youtube <> 0;

-- ------------------------------------------------------------------------------------------------------------
-- Advanced problems
-- ------------------------------------------------------------------------------------------------------------

-- Q10. Find the top 3 most-viewed tracks for each artist using window functions.
WITH t1 AS
	(SELECT
		artist,
		track,
		SUM(views) AS Total_views,
		DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views)DESC) AS Rank
	FROM spotify 
	GROUP BY artist, track
	ORDER BY artist, Total_views DESC
	)
SELECT * FROM t1
WHERE rank <= 3

-- Q11. Write a query to find tracks where the liveness score is above average.
SELECT * FROM spotify

SELECT
	track,
	liveness,
	(SELECT AVG(liveness) AS Avg_liveness FROM spotify)
FROM spotify
WHERE liveness > (SELECT AVG(liveness) AS Avg_liveness FROM spotify)
GROUP BY track, liveness
ORDER BY liveness DESC;

-- Q12. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album
WITH t1 AS
	(SELECT
		album,
		MAX(energy) AS Highest_energy,
		MIN(energy) AS Lowest_energy
	FROM spotify
	GROUP BY album
	)
SELECT 
	album, 
	Highest_energy, 
	Lowest_energy, 
	ROUND((Highest_energy - Lowest_energy)::numeric,2) AS Diff_energy 
FROM t1
ORDER BY Diff_energy DESC;

-- Q13. Find tracks where the energy-to-liveness ratio is greater than 1.2.
WITH t1 AS
	(SELECT
		track,
		energy,
		liveness,
		(energy/NULLIF(liveness,0)) AS EtoL_ratio
	FROM spotify
	)
SELECT * FROM t1
WHERE EtoL_ratio > 1.2
ORDER BY EtoL_ratio;

-- Q14. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
WITH t1 AS (
  SELECT
    track,
    SUM(likes)  AS total_likes,
    MAX(views)  AS highest_view
  FROM spotify
  GROUP BY track
)
SELECT
  track,
  highest_view,
  SUM(total_likes) OVER (
    ORDER BY highest_view DESC, track
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cum_likes
FROM t1
ORDER BY highest_view DESC, track;
	
	