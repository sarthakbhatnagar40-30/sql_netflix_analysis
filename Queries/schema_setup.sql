-- Netflix Project

create table netflix
(
	show_id varchar(10),
	"type" varchar(10),
	title text,
	director text,
	"cast" text, 
	country text, 
	date_added text, 
	release_year int,
	rating varchar(10),
	duration varchar(10),
	listed_in text, 
	description text
);