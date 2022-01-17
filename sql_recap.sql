Use imdb_ijs;

#The big picture

#How many actors are there in the actors table? 816873 unique actors
select count(distinct concat(first_name, last_name)) as num_actors from actors;

#How many directors are there in the directors table? 86843 unique directos
select count(distinct concat(first_name, last_name)) as num_directors from directors;

#How many movies are there in the movies table? 388215 unique movies
select count(distinct concat(name, year)) as num_movies from movies;

# Select all the films that are duplicated. #Films that have the same title and are from the same year
select concat(name,year) as title_year, count(*) from movies
Group by title_year having count(*) > 1;

#Exploring the movies

#From what year are the oldest and the newest movies? What are the names of those movies?
Select name, year from movies
order by year asc limit 2; #oldest movies 'Traffic Crossing Leeds Bridge' and 'Roundhay Garden Scene'
Select name, year from movies
order by year desc limit 1; # newest movie - 'Harry Potter and the Half-Blood Prince'

#What movies have the highest and the lowest ranks?
select name, year, movies.rank from movies
order by movies.rank desc limit 20; # highest ranked movies
select name, year, movies.rank from movies
where movies.rank is not null
order by movies.rank asc limit 20; # lowest ranked movies

#What is the most common movie title? Eurovision Song Contest, The
select name, count(*) from movies
group by name having count(*) > 1
order by count(*) desc limit 5;


#Understanding the database

#Are there movies with multiple directors? yes
select count(director_id), movie_id from movies_directors
group by movie_id order by count(director_id) desc limit 10;

#What is the movie with the most directors? Why do you think it has so many? - The Bill - because it is a TV Series
select name, year, movies.rank, count(director_id), movie_id from movies_directors
join movies on movies_directors.movie_id = movies.id
group by movie_id order by count(director_id) desc limit 10;

#On average, how many actors are listed by movie? 11,4303
select avg(count) from
	(
    select count(actor_id) as count from roles
	group by movie_id
    ) as avg_count;
#Are there movies with more than one “genre”? yes
select movie_id, count(genre) from movies_genres
group by movie_id order by count(genre) desc;

#Who directed most movies? Dave Fleischer
select first_name, last_name, director_id, count(movie_id) from movies_directors
join directors on movies_directors.director_id = directors.id
group by director_id order by count(movie_id) desc limit 5;

#Looking for specific movies

#Can you find the movie called “Pulp Fiction”? yes - movie_id 267038
Select * from movies
where name like 'Pulp Fiction';

#Who directed it? Quentin Tarantino
Select movie_id, first_name, last_name from movies_directors
join directors on movies_directors.director_id = directors.id
where movie_id = 267038;

Select movie_id, first_name, last_name from movies_directors
join directors on movies_directors.director_id = directors.id
join movies on movies_directors.movie_id = movies.id
where name like 'Pulp Fiction';

#Which actors where casted on it? 
select movie_id, actors.first_name, actors.last_name from movies
join roles on movies.id = roles.movie_id
join actors on roles.actor_id = actors.id
where name like 'Pulp Fiction';

#Can you find the movie called “La Dolce Vita”? yes, movie_id 89572
Select * from movies
#where name like 'Dolce vita%';
where name like 'Dolce vita, La';

#Who directed it? Federico Fellini
Select movie_id, first_name, last_name from movies_directors
join directors on movies_directors.director_id = directors.id
join movies on movies_directors.movie_id = movies.id
where name like 'Dolce vita, La';

#Which actors where casted on it?
select movie_id, actors.first_name, actors.last_name from movies
join roles on movies.id = roles.movie_id
join actors on roles.actor_id = actors.id
where name like 'Dolce vita, La';

#When was the movie “Titanic” by James Cameron released? 1997
select name,year,first_name, last_name from movies
join movies_directors on movies.id = movies_directors.movie_id
join directors on movies_directors.director_id = directors.id
where name = 'Titanic'
and first_name like 'James%'
and last_name ='Cameron';

#Hint: there are many movies named “Titanic”. We want the one directed by James Cameron.
#Hint 2: the name “James Cameron” is stored with a weird character on it.

#Actors and directors

#Who is the actor that acted more times as “Himself”? Adolf Hitler. because of many documentations about him and ww2
select first_name, last_name, actor_id, count(*) from roles
join actors on roles.actor_id = actors.id
join movies on roles.movie_id = movies.id
where role = 'Himself'
group by actor_id order by count(*) desc;

#What is the most common name for actors? And for directors? Actors: Shauna Mac Donald, Directors: Kaoru Umezawa
select concat(first_name, last_name) as full_name, count(*) from actors
Group by full_name having count(*) > 1 order by count(*) desc;
select concat(first_name, last_name) as full_name, count(*) from directors
Group by full_name having count(*) > 1 order by count(*) desc;

#Analysing genders

#How many actors are male and how many are female? Male: 513306. Female: 304412
select gender, count(*) as num from actors
group by gender;

#Answer the questions above both in absolute and relative terms. Male: 62,773 %, Female: 37,227%
select gender, count(*) * 100 / sum(count(*)) over()
from actors
group by gender;

#Movies across time

#How many of the movies were released after the year 2000? 46006 movies were released after 2000
select count(*) as movies_after_2000 from movies
where year > 2000;

#How many of the movies where released between the years 1990 and 2000? 91138 movies were released between 1990 and 2000
select count(*) as movies_after_2000 from movies
where year between 1990 and 2000;

#Which are the 3 years with the most movies?  2002 (12056 movies), 2003 (11890 movies), 2001 (11690 movies)
#How many movies were produced on those years? 2002 (12056 movies), 2003 (11890 movies), 2001 (11690 movies)
select year, count(*) from movies
group by year order by count(*) desc limit 3;

#What are the top 5 movie genres? Short, Drama, Comedy, Documentary, Animation

select genre,count(*) from movies_genres
group by genre order by count(*) desc limit 5;

#What are the top 5 movie genres before 1920? Short, Comedy, Drama, Documentary, Western
select genre,count(*) from movies_genres
join movies on movies_genres.movie_id = movies.id
where year < 1920
group by genre order by count(*) desc limit 5;

#What is the evolution of the top movie genres across all the decades of the 20th century?

select (floor(year / 10) * 10) as decade, genre from movies
join movies_genres on movies.id = movies_genres.movie_id
group by decade order by decade asc;

#Putting it all together: names, genders and time

#Has the most common name for actors changed over time?
select concat(first_name, last_name) as full_name, (floor(year / 10) * 10) as decade, count(*) from actors
join roles on roles.actor_id = actors.id
join movies on movies.id = roles.movie_id
Group by decade, full_name having count(*) > 1 order by count(*), decade desc;

#Get the most common actor name for each decade in the XX century.

#Re-do the analysis on most common names, splitted for males and females.

#Is the proportion of female directors (I guess actors as there are no genders for directors) greater after 1968, compared to before 1968?

#What is the movie genre where there are the most female directors? Answer the question both in absolute and relative terms.

#How many movies had a majority of females among their cast? Answer the question both in absolute and relative terms.