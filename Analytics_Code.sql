-- Using the IMDB Database/Schema

USE imdb;

-- Segment 1: Database - Tables, Columns, Relationships

/* Now that we have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, we will take a look at 'movies' and 'genre' tables.*/

-- Find the total number of rows in each table of the schema?

SELECT table_name,
       table_rows
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_SCHEMA = 'imdb'; 

-- Which columns in the movie table have null values?

describe MOVIE;
describe GENRE;
SELECT 'ID',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  ID IS NULL
UNION
SELECT 'Title',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  TITLE IS NULL
UNION
SELECT 'Year',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  YEAR IS NULL
UNION
SELECT 'Date Published',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  DATE_PUBLISHED IS NULL
UNION
SELECT 'Movie',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  DURATION IS NULL
UNION
SELECT 'Country',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  COUNTRY IS NULL
UNION
SELECT 'WorldWide_Gross',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  WORLWIDE_GROSS_INCOME IS NULL
UNION
SELECT 'Languages',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  LANGUAGES IS NULL
UNION
SELECT 'Prod Company',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  PRODUCTION_COMPANY IS NULL; 

-- country, worlwide_gross_income, languages and production_company columns have NULL values.

---------------------------------------------------------------------------------------------------------
-- Segment 2: Movie Release Trends

-- Now as we can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Find the total number of movies released each year? 
-- How does the trend look month wise?

-- Number of movies released anually.
SELECT Year,
       COUNT(TITLE) AS 'number_of_movies'
FROM   MOVIE
GROUP  BY YEAR;

-- Number of movies released every month.
SELECT MONTH(DATE_PUBLISHED) AS'month_num',
       COUNT(TITLE)          AS 'number_of_movies'
FROM   MOVIE
GROUP  BY YEAR, MONTH(DATE_PUBLISHED)
ORDER  BY COUNT(TITLE) DESC; 

/*The highest number of movies is produced in the month of March.
So, now that we have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- How many movies were produced in the USA or India in the last year (2019)?

SELECT year,
       COUNT(TITLE) AS number_of_movies
FROM   MOVIE
WHERE  YEAR = 2019
       AND ( COUNTRY LIKE '%USA%'
              OR COUNTRY LIKE '%India%' )
GROUP  BY YEAR; 

/* Out of 2001 movies produced in 2019, USA/INDIA produced 1059 movies.*/


--------------------------------------------------------------------------------------------------
/* Segment 3: Production Statistics and Genre Analysis

Let’s find out the different genres in the dataset.*/

-- Find the unique list of the genres present in the data set?

SELECT DISTINCT genre
FROM   GENRE; 

/* So, Hollywood plans to make a movie out of one of these genres.
Combining both the movie and genres table can give more interesting insights. */

-- Which genre had the highest number of movies produced overall?

SELECT g.genre,
       COUNT(m.TITLE) AS no_of_movies
FROM   MOVIE m
       INNER JOIN GENRE g
               ON g.MOVIE_ID = m.ID
GROUP  BY g.GENRE
ORDER  BY COUNT(m.TITLE) DESC
LIMIT  1; 

/* So, based on the insight that we just drew, Hollywood Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- How many movies belong to only one genre?

WITH AGG
     AS (SELECT m.ID,
                Count(g.GENRE) AS GenC
         FROM   MOVIE m
                INNER JOIN GENRE g
                        ON g.MOVIE_ID = m.ID
         GROUP  BY m.ID
         HAVING Count(g.GENRE) = 1)
		
SELECT Count(ID) AS movie_count
FROM   AGG; 

/* There are 3289 movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of Hollywood Movies next project.*/

-- What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

SELECT g.genre,
       ROUND(AVG(m.DURATION), 2) AS avg_duration
FROM   MOVIE m
       INNER JOIN GENRE g
               ON g.MOVIE_ID = m.ID
GROUP  BY g.GENRE
ORDER  BY ROUND(AVG(m.DURATION), 2) DESC;  
 

/* Now we know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Genre 'action' has the highest  avg duration of 112.88 mins.
Lets find the movies of genre 'action' on the basis of number of movies.*/

-- What is the rank of the ‘action’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)

WITH GENRE_RANKS
     AS (SELECT genre,
                Count(MOVIE_ID)                    AS 'movie_count',
                RANK()
                  OVER(
                    ORDER BY Count(MOVIE_ID) DESC) AS genre_rank
         FROM   GENRE
         GROUP  BY GENRE)
SELECT *
FROM   GENRE_RANKS
WHERE  GENRE = 'action'; 

-- action movies is in rank 4 among all genres in terms of number of movies.

-- What is the rank of the ‘action’ genre of movies among all the genres in terms of number of movies produced? 
 
WITH GENRE_RANKS
     AS (SELECT genre,
                Count(MOVIE_ID)                    AS 'movie_count',
                RANK()
                  OVER(
                    ORDER BY Count(MOVIE_ID) DESC) AS genre_rank
         FROM   GENRE
         GROUP  BY GENRE)
SELECT *
FROM   GENRE_RANKS
WHERE  GENRE = 'thriller'; 

-- GENRE THRILLER IS AT RANK 3.
 
 --------------------------------------------------------------------------------------
 /*
 Segment 4: Ratings Analysis 
 
 In this segment, we will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Find the minimum and maximum values in each column of the ratings table except the movie_id column?

SELECT ROUND(MIN(AVG_RATING), 1) AS min_avg_rating,
       ROUND(MAX(AVG_RATING), 1) AS max_avg_rating,
       MIN(TOTAL_VOTES)          AS min_total_votes,
       MAX(TOTAL_VOTES)          AS max_total_votes,
       MIN(MEDIAN_RATING)        AS min_media_rating,
       MAX(MEDIAN_RATING)        AS max_media_rating
FROM   RATINGS; 

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Which are the top 10 movies based on average rating?

SELECT     M.title,
           R.avg_rating,
           RANK() OVER(ORDER BY R.AVG_RATING DESC) AS movie_rank
FROM       RATINGS R
INNER JOIN MOVIE M
ON         R.MOVIE_ID=M.ID
ORDER BY   R.AVG_RATING DESC
LIMIT      10;

/*So, now that we know the top 10 movies, do we think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give a good insight.*/

-- Summarise the ratings table based on the movie counts by median ratings.

SELECT median_rating,
       COUNT(MOVIE_ID) AS movie_count
FROM   RATINGS
GROUP  BY MEDIAN_RATING
ORDER  BY COUNT(MOVIE_ID) DESC; 

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which Hollywood Movies can partner for its next project.*/

-- Which production house has produced the most number of hit movies (average rating > 8)??

WITH AGG
AS
  (
             SELECT     M.production_company,
                        M.ID,
                        R.AVG_RATING
             FROM       MOVIE M
             INNER JOIN RATINGS R
             ON         M.ID=R.MOVIE_ID
             WHERE      AVG_RATING>8
             ORDER BY   R.AVG_RATING DESC ),
 AGG1 AS
  (
  SELECT   production_company,
           COUNT(ID)                             AS movie_count,
           RANK() OVER (ORDER BY COUNT(ID) DESC) AS prod_company_rank
  FROM     AGG
  WHERE    PRODUCTION_COMPANY IS NOT NULL
  GROUP BY PRODUCTION_COMPANY
  ORDER BY MOVIE_COUNT DESC)
  
  SELECT * FROM AGG1 WHERE prod_company_rank=1;

-- How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

WITH AGG
     AS (SELECT g.genre,
                r.MOVIE_ID,
                m.DATE_PUBLISHED,
                m.COUNTRY
         FROM   RATINGS r
                INNER JOIN GENRE g
                        ON r.MOVIE_ID = g.MOVIE_ID
                INNER JOIN MOVIE m
                        ON g.MOVIE_ID = m.ID
         WHERE  r.TOTAL_VOTES > 1000
                AND Month(m.DATE_PUBLISHED) = 3
                AND Year(m.DATE_PUBLISHED) = 2017
                AND m.COUNTRY IN ( 'USA' ))
SELECT GENRE,
       Count(MOVIE_ID) AS movie_count
FROM   AGG
GROUP  BY GENRE
ORDER  BY Count(MOVIE_ID) DESC; 

-- Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?

SELECT m.title,
       r.avg_rating,
       g.genre
FROM   GENRE g
       INNER JOIN RATINGS r
               ON g.MOVIE_ID = r.MOVIE_ID
       INNER JOIN MOVIE m
               ON g.MOVIE_ID = m.ID
WHERE  r.AVG_RATING > 8
       AND LOWER(m.TITLE) LIKE 'the%'
ORDER  BY r.AVG_RATING DESC; 

------------------------------------------------------------------------------------------------------
/* Segment 5: Crew Analysis

Now that we have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/

-- Which columns in the names table have null values??

SELECT COUNT(*) - COUNT(ID)               AS id_nulls,
       COUNT(*) - COUNT(NAME)             AS name_nulls,
       COUNT(*) - COUNT(HEIGHT)           AS height_nulls,
       COUNT(*) - COUNT(DATE_OF_BIRTH)    AS date_of_birth_nulls,
       COUNT(*) - COUNT(KNOWN_FOR_MOVIES) AS known_for_movies_nulls
FROM   NAMES; 

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by Hollywood Movies.*/

-- Who are the top three directors in the top three genres whose movies have an average rating > 8?

WITH TOP_3_GENRE
AS
  (
             SELECT     GENRE
             FROM       RATINGS R
             INNER JOIN MOVIE M
             ON         R.MOVIE_ID=M.ID
             INNER JOIN GENRE
             USING      (MOVIE_ID)
             WHERE      AVG_RATING > 8
             GROUP BY   GENRE
             ORDER BY   COUNT(GENRE) DESC
             LIMIT      3 )
  SELECT     NAME        AS director_name,
             COUNT(NAME) AS movie_count
  FROM       RATINGS R
  INNER JOIN MOVIE M
  ON         R.MOVIE_ID=M.ID
  INNER JOIN GENRE
  USING      (MOVIE_ID)
  INNER JOIN DIRECTOR_MAPPING D
  USING      (MOVIE_ID)
  INNER JOIN NAMES N
  ON         D.NAME_ID=N.ID
  WHERE      GENRE IN
             (
                    SELECT *
                    FROM   TOP_3_GENRE)
  AND        AVG_RATING>8
  GROUP BY   NAME
  ORDER BY   COUNT(NAME) DESC
  LIMIT      3 ;

/* James Mangold can be hired as the director for Hollywood's next project. 
Now, let’s find out the top two actors.*/

-- Who are the top two actors whose movies have a median rating >= 8?

SELECT NAME        AS actor_name,
       COUNT(NAME) AS movie_count
FROM   NAMES N
       INNER JOIN ROLE_MAPPING RO
               ON N.ID = RO.NAME_ID
       INNER JOIN RATINGS RA
               ON RO.MOVIE_ID = RA.MOVIE_ID
WHERE  MEDIAN_RATING >= 8
       AND CATEGORY = 'actor'
GROUP  BY NAME
ORDER  BY COUNT(NAME) DESC
LIMIT  2; 

/* Hollywood Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Which are the top three production houses based on the number of votes received by their movies?

SELECT     production_company,
           SUM(TOTAL_VOTES)                                  AS vote_count,
           DENSE_RANK() OVER(ORDER BY SUM(TOTAL_VOTES) DESC) AS prod_comp_rank
FROM       MOVIE M
INNER JOIN RATINGS RA
ON         M.ID=RA.MOVIE_ID
GROUP BY   PRODUCTION_COMPANY
LIMIT      3;

/* So, these are the top three production houses based on the number of votes received by the movies they have produced.
Since Hollywood is based out of Mumbai, India also wants to woo its local audience. 
Hollywood also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Rank actors with movies released in India based on their average ratings. 
-- Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: We should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

WITH ACTORS
AS
  (
             SELECT     NAME                                                       AS actor_name ,
                        SUM(TOTAL_VOTES)                                           AS total_votes,
                        COUNT(NAME)                                                AS movie_count,
                        ROUND(SUM(AVG_RATING * TOTAL_VOTES) / SUM(TOTAL_VOTES), 2) AS actor_avg_rating
             FROM       NAMES N
             INNER JOIN ROLE_MAPPING RO
             ON         N.ID = RO.NAME_ID
             INNER JOIN MOVIE M
             ON         RO.MOVIE_ID = M.ID
             INNER JOIN RATINGS RA
             ON         M.ID = RA.MOVIE_ID
             WHERE      COUNTRY REGEXP 'india'
             AND        CATEGORY = 'actor'
             GROUP BY   NAME
             HAVING     MOVIE_COUNT >= 5)
  SELECT   *,
           DENSE_RANK() OVER ( ORDER BY ACTOR_AVG_RATING DESC, TOTAL_VOTES DESC) AS actor_rank
  FROM     ACTORS;

-- Top actor is Vijay Sethupathi

-- Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: We should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

WITH ACTRESS
AS
  (
             SELECT     NAME AS actress_name,
                        SUM(TOTAL_VOTES)                                      AS total_votes,
                        COUNT(NAME)                                           AS movie_count,
                        ROUND(SUM(AVG_RATING*TOTAL_VOTES)/SUM(TOTAL_VOTES),2) AS actress_avg_rating
             FROM       NAMES N
             INNER JOIN ROLE_MAPPING RO
             ON         N.ID=RO.NAME_ID
             INNER JOIN MOVIE M
             ON         RO.MOVIE_ID=M.ID
             INNER JOIN RATINGS RA
             USING     (MOVIE_ID)
             WHERE      LANGUAGES REGEXP 'hindi'
             AND        COUNTRY REGEXP 'india'
             AND        CATEGORY = 'actress'
             GROUP BY   NAME
             HAVING     MOVIE_COUNT>=3 )
  SELECT   *,
           DENSE_RANK() OVER(ORDER BY ACTRESS_AVG_RATING DESC, TOTAL_VOTES DESC) AS actress_rank
  FROM     ACTRESS
  LIMIT    5;

--  Taapsee Pannu tops with average rating 7.74. 
-------------------------------------------------------------------------------------------------

/* Segment 6: Broader Understanding of Data

Now let us divide all the action movies in the following categories and find out their numbers.*/

/* Select action movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies */

SELECT TITLE AS movie,
       AVG_RATING,
       CASE
         WHEN AVG_RATING > 8 THEN 'Superhit movies'
         WHEN AVG_RATING BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN AVG_RATING BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         WHEN AVG_RATING < 5 THEN 'Flop movies'
       END   AS 'avg_rating_category'
FROM   GENRE g
       INNER JOIN RATINGS ra USING(MOVIE_ID)
       INNER JOIN MOVIE m
               ON ra.MOVIE_ID = m.ID
WHERE  GENRE = 'action'; 

/* Until now, we have analysed various tables of the data set. 
Now, we will perform some tasks that will give we a broader understanding of the data in this segment.*/

-- What is the genre-wise running total and moving average of the average movie duration? 

WITH GENRE
     AS (SELECT GENRE,
                ROUND(AVG(DURATION), 2)                      AS avg_duration,
                SUM(AVG(DURATION))
                  OVER (
                    ORDER BY GENRE ROWS UNBOUNDED PRECEDING) AS
                running_total_duration,
                AVG(AVG(DURATION))
                  OVER (
                    ORDER BY GENRE ROWS UNBOUNDED PRECEDING) AS
                moving_avg_duration
         FROM   MOVIE m
                INNER JOIN GENRE g
                        ON m.ID = g.MOVIE_ID
         GROUP  BY GENRE)
SELECT genre,
       avg_duration,
       ROUND(RUNNING_TOTAL_DURATION, 2) AS running_total_duration,
       ROUND(MOVING_AVG_DURATION, 2)    AS moving_avg_duration
FROM   GENRE;

-- Let us find top 5 grossing movies of each year with top 3 genres.
-- Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- Top 3 Genres based on most number of movies

WITH TOP_3_GENRE
AS
  (
           SELECT   GENRE
           FROM     GENRE
           GROUP BY GENRE
           ORDER BY COUNT(GENRE) DESC
           LIMIT    3 ),
  TOP_MOVIES
AS
  (
             SELECT     genre,
                        year,
                        TITLE                                                                                                                     AS movie_name,
                        CAST(REPLACE(IFNULL(WORLWIDE_GROSS_INCOME,0),'$ ','') AS DECIMAL(10))                                                     AS worldwide_gross_income_$,
                        ROW_NUMBER() OVER (PARTITION BY YEAR ORDER BY CAST(REPLACE(IFNULL(WORLWIDE_GROSS_INCOME,0),'$ ','') AS DECIMAL(10)) DESC) AS movie_rank
             FROM       MOVIE M
             INNER JOIN GENRE G
             ON         M.ID = G.MOVIE_ID
             WHERE      GENRE IN
                        (
                               SELECT *
                               FROM   TOP_3_GENRE) )
  SELECT *
  FROM   TOP_MOVIES
  WHERE  MOVIE_RANK<=5;

-- Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?

SELECT     production_company,
           COUNT(PRODUCTION_COMPANY)                                  AS movie_count ,
           DENSE_RANK() OVER(ORDER BY COUNT(PRODUCTION_COMPANY) DESC) AS prod_comp_rank
FROM       MOVIE M
INNER JOIN RATINGS RA
ON         M.ID=RA.MOVIE_ID
WHERE      MEDIAN_RATING>=8
AND        LANGUAGES REGEXP ','
GROUP BY   PRODUCTION_COMPANY
LIMIT      2;

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?

SELECT     NAME                                                  AS actress_name,
           SUM(TOTAL_VOTES)                                      AS total_votes,
           COUNT(NAME)                                           AS movie_count,
           ROUND(SUM(AVG_RATING*TOTAL_VOTES)/SUM(TOTAL_VOTES),2) AS actress_avg_rating,
           ROW_NUMBER() OVER (ORDER BY COUNT(NAME) DESC)         AS actress_rank
FROM       GENRE G
INNER JOIN MOVIE M
ON         G.MOVIE_ID=M.ID
INNER JOIN RATINGS RA
USING     (MOVIE_ID)
INNER JOIN ROLE_MAPPING RO
USING      (MOVIE_ID)
INNER JOIN NAMES N
ON         RO.NAME_ID=N.ID
WHERE      AVG_RATING >8
AND        GENRE = 'drama'
AND        CATEGORY = 'actress'
GROUP BY   NAME
LIMIT      3;

/* Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations
*/

WITH NEXT_DATE_PUBLISH
AS
  (
             SELECT     NAME_ID AS DIRECTOR_ID,
                        NAME    AS DIRECTOR_NAME,
                        DATE_PUBLISHED,
                        AVG_RATING,
                        TOTAL_VOTES,
                        DURATION,
                        LEAD(DATE_PUBLISHED,1) OVER(PARTITION BY NAME_ID ORDER BY DATE_PUBLISHED) AS NEXT_DATE_PUBLISHED
             FROM       DIRECTOR_MAPPING D
             INNER JOIN NAMES N
             ON         D.NAME_ID=N.ID
             INNER JOIN MOVIE M
             ON         D.MOVIE_ID=M.ID
             INNER JOIN RATINGS RA
             USING     (MOVIE_ID) )
  SELECT   director_id,
           director_name,
           COUNT(DIRECTOR_NAME)                                       AS number_of_movies,
           ROUND(AVG(DATEDIFF(NEXT_DATE_PUBLISHED,DATE_PUBLISHED)),0) AS avg_inter_movie_days,
           ROUND(AVG(AVG_RATING),2)                                   AS avg_rating,
           SUM(TOTAL_VOTES)                                           AS total_votes,
           MIN(AVG_RATING)                                            AS min_rating,
           MAX(AVG_RATING)                                            AS max_rating,
           SUM(DURATION)                                              AS total_duration
  FROM     NEXT_DATE_PUBLISH
  GROUP BY DIRECTOR_ID
  ORDER BY NUMBER_OF_MOVIES DESC
  LIMIT    9;