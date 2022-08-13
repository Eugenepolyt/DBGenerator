DROP TRIGGER IF EXISTS delete_different_games ON item_hero_statistic;
DROP FUNCTION IF EXISTS delete_different_games;
DROP TABLE IF EXISTS top_hero_players;
DROP TABLE IF EXISTS item_hero_statistic;
DROP TABLE IF EXISTS popular_cosmetics;
DROP TABLE IF EXISTS characteristic;
DROP TABLE IF EXISTS abilities;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS hero;
DROP TABLE IF EXISTS game;

CREATE TABLE game
(
	game_id serial PRIMARY KEY,
	game_name varchar(50) UNIQUE NOT NULL,
	release_date date NOT NULL
);

DROP TYPE IF EXISTS attack;
CREATE type attack as ENUM ('ranged', 'melee');

CREATE TABLE hero
(
	hero_id serial PRIMARY KEY,
	game_id integer REFERENCES game(game_id) NOT NULL,
	hero_name varchar(40) NOT NULL,
	attack_type attack NOT NULL,
	winrate NUMERIC(10, 2) NOT NULL,
    
    UNIQUE(game_id, hero_name)
);

DROP TYPE IF EXISTS rare_type;
CREATE type rare_type as ENUM (
	'common', 
	'uncommon', 
	'rare',  
	'mythical',
	'legendary',
	'immortal',
	'arcana'
);

CREATE TABLE popular_cosmetics
(
	hero_id integer REFERENCES hero(hero_id) NOT NULL,
	cosmetic_name varchar(50) NOT NULL,
	rare rare_type NOT NULL,
	price NUMERIC(10, 2) NOT NULL
);

DROP TYPE IF EXISTS spell_type;
CREATE type spell_type as ENUM ('active', 'passive');

CREATE TABLE abilities
(
	hero_id integer REFERENCES hero(hero_id) NOT NULL,
	ability_name varchar(30) NOT NULL,
	ability_type spell_type NOT NULL,
	manacost integer,
	cooldown NUMERIC(10, 2),
	description text NOT NULL
);

CREATE TABLE characteristic
(
	hero_id integer REFERENCES hero(hero_id) NOT NULL,
	damage integer NOT NULL,
	armor NUMERIC(10, 2) NOT NULL,
	movespeed integer NOT NULL,
	attack_speed NUMERIC(10, 1) NOT NULL
);


CREATE TABLE items
(
	item_id serial PRIMARY KEY,
	game_id integer REFERENCES game(game_id) NOT NULL,
	item_name varchar(30) NOT NULL,
	price integer NOT NULL,
	popularity integer NOT NULL,
	winrate NUMERIC(10, 2) NOT NULL,
 
    UNIQUE(game_id, item_name)
);

CREATE TABLE item_hero_statistic
(
	hero_id integer REFERENCES hero(hero_id) NOT NULL,
	item_id integer REFERENCES items(item_id) NOT NULL,
	matches_cnt integer NOT NULL,
	winrate NUMERIC(10, 2) NOT NULL
);

CREATE TABLE top_hero_players
(
	hero_id integer REFERENCES hero(hero_id) NOT NULL,
    nickname varchar(30) NOT NULL,
	matches_cnt integer NOT NULL,
	winrate NUMERIC(10, 2) NOT NULL,
	kda NUMERIC(10, 2) NOT NULL,
 
    CHECK (winrate > 50.0),
    CHECK (matches_cnt > 500)
);
