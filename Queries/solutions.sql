select * from  netflix;

select
	count(*) as total_content
from netflix;

select 
	distinct "type"
from netflix;

-- Solutions for Businees problems

-- 1. Count the number of Movies vs TV Shows
select 
"type",
count(*)
from netflix 
group by "type";

-- 2. Find the most common rating for movies and TV shows
select 
	"type",
	rating
from 
(	select
		"type",
		rating, 
		count(*) as count_of_rating,
	rank() over(partition by "type" order by count(*) desc) as ranking
	from netflix
	group by "type", rating
) as t1 
where ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
select *
from netflix
where release_year = '2020' and "type" = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix
select 
	trim(unnest(string_to_array(country, ','))) as countries,
	count(*) 
from netflix
group by trim(unnest(string_to_array(country, ',')))
order by count(*) desc
limit 5;

-- 5. Identify the longest movie
select *
from netflix
where "type" = 'Movie' and duration is not null
order by split_part(duration, ' ', 1)::int desc 
limit 1;

-- 6. Find content added in the last 5 years
select *
from netflix
where to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * 
from netflix
where director ilike '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
select * 
from netflix
where "type" = 'TV Show' 
and 
split_part(duration, ' ', 1)::int > 5;

-- 9. Count the number of content items in each genre
select 
	trim(unnest(string_to_array(listed_in, ','))) as genre,
	count(*)
from netflix
group by trim(unnest(string_to_array(listed_in, ',')));

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
select
	year_added,
	count(*) as yearly_content,
	round(count(*) / sum(count(*)) over () * 100, 2) as avg_content_per_year
from 
(
	select
		trim(unnest(string_to_array(country, ','))) as countries,
		date_part('year', to_date(date_added, 'Month, DD, YYYY')) as year_added
	from netflix 
)
where countries = 'India'
group by year_added
order by avg_content_per_year desc;

-- 11. List all movies that are documentaries
select * 
from netflix
where listed_in ilike '%documentaries%';

-- 12. Find all content without a director
select * 
from netflix 
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * 
from netflix
where "cast" ilike '%salman khan%'
and 
"type" = 'Movie'
and 
release_year >= date_part('year', current_date) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
-- Method 1:
select 
	trim(unnest(string_to_array("cast", ','))) as "actors", 
	count(*) as "frequency"
from 
(
	select
		trim(unnest(string_to_array(country, ','))) as countries,
		"cast"
	from netflix 
	where "type" = 'Movie'
)
where countries = 'India' 
group by trim(unnest(string_to_array("cast", ',')))
order by count(*) desc
limit 10;

-- Method 2:
select 
trim(unnest(string_to_array("cast", ','))) as actors,
count(*) as "frequency"
from netflix
where "type" = 'Movie'
and 
country ilike '%india%'
and 
"cast" is not null
group by trim(unnest(string_to_array("cast", ',')))
order by count(*) desc
limit 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
with t1 
as
(select *,
	case 
		when
			description ilike '%kill%' or description ilike '%violence%'
			then 'Bad Content'
				else 'Good Content'
				 end as category
from netflix
)
select 
	category,
	count(*) as total_content
from t1
group by category;