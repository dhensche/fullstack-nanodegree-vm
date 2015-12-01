-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.


CREATE TABLE players (
	username TEXT,
	id SERIAL PRIMARY KEY
	);

CREATE TABLE matches (
	winner INTEGER NOT NULL REFERENCES players (id),
	loser INTEGER REFERENCES players (id),
	CHECK (winner <> loser)
	);

CREATE VIEW standings AS 
SELECT 
	p.id, 
	p.username, 
	count(m.*) as wins, 
	(select count(*) from matches am where am.winner = p.id or am.loser = p.id) as matches
from players p 
left join matches m on m.winner = p.id 
group by p.id, p.username order by wins desc, p.id;

create view pairings as with 
	odds as (select * from (select id, username, row_number() over() as rn from standings) as v where rn % 2 = 1), 
	evens as (select * from (select id, username, row_number() over() as rn from standings) as v where rn % 2 = 0) 
select 
	odds.id as player1_id, 
	odds.username as player1_username, 
	evens.id as player2_id, 
	coalesce(evens.username, 'bye') as player2_username 
from odds
left join evens on odds.rn = evens.rn - 1;