-- This is the script for creating the schema for this project
-- the csv files in the database_csvs/ subdirectory will be imported into the tables created here
-- For detailed descriptions of the input datasets, please consult the database_csvs/input_data_descriptions.md


create schema if not exists og_demeco;

-- noc info: names and codes of noc/npc and which geographical entity they correspond to 
-- import the database_csvs/noc_to_demeco_entity_conversion_table.csv to this table
create table if not exists noc_info (
	noc_code CHAR(3) primary key,
	noc_name VARCHAR(75),
	demeco_entity_name VARCHAR(75)
);

-- demeco entity info: names of each geographical entity represented in the demographic and economic (demeco) datasets and which noc/npc they correspond to
-- import demeco_entity_to_noc_conversion_table.csv here
create table if not exists demeco_entity_info (
	demeco_entity_name VARCHAR(75) primary key,
	noc_code CHAR(3),
	noc_name VARCHAR(75),
	foreign key (noc_code) references noc_info(noc_code)
);


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- medal count tables
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- medal tables for recent OGs
-- import the database_csvs/medal_table_20*_o.csv files into the following tables. make sure the year matches

create table if not exists medal_table_2024 (
	noc_code CHAR(3) primary key,
	gold INT,
	silver INT,
	bronze INT,
	foreign key (noc_code) references noc_info(noc_code)
);

create table if not exists medal_table_2022 (
	noc_code CHAR(3) primary key,
	gold INT,
	silver INT,
	bronze INT,
	foreign key (noc_code) references noc_info(noc_code)
);


create table if not exists medal_table_2020 (
	noc_code CHAR(3) primary key,
	gold INT,
	silver INT,
	bronze INT,
	foreign key (noc_code) references noc_info(noc_code)
);

create table if not exists medal_table_2018 (
	noc_code CHAR(3) primary key,
	gold INT,
	silver INT,
	bronze INT,
	foreign key (noc_code) references noc_info(noc_code)
);


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- tables for the demographic and economic (demeco) datasets
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*
create tables for the demographic/economical datasets (demeco datasets)
here, entity_name are used as foreign key to reference the entity_name column of the demeco_entity_info table. 
However, lots of geographical entities in these demeco datasets are not included in the demeco_entity_info table, 
reason being that the demeco_entity_info table only includes entities that have a corresponding NOC that participates at the OGs.
many of the entities in the demeco datasets do not have a corresponding noc that participate at the OGs (e.g. Greenland, Scotland, French Polynesia, European Union, etc.), 
To avoid SQL's foreign key error when importing data, data will be first loaded into a staging table that has the same structure as the actual table 
but without the foreign key constraint. 
Then we import the staging table into the actual table after fitlering out entities that are not part of the demeco_entity_info table.
*/

-- GPD per capita
-- import the database_csvs/gdp_per_capita.csv into this table
create table if not exists gdp_per_capita_staging_table (
	entity_name VARCHAR(75),
	year_of_data INT,
	gdp_per_capita_val NUMERIC
);


create table if not exists gdp_per_capita (
	entity_name VARCHAR(75),
	year_of_data INT,
	gdp_per_capita_val NUMERIC,
	foreign key (entity_name) references demeco_entity_info(demeco_entity_name)
);

insert into gdp_per_capita (entity_name, year_of_data, gdp_per_capita_val)
select * 
from gdp_per_capita_staging_table
where entity_name in (select demeco_entity_name from demeco_entity_info)
on CONFLICT DO NOTHING; 

-- populations
-- import the database_csvs/populations.csv into this table
create table if not exists pop_staging_table (
	entity_name VARCHAR(75),
	year_of_data INT,
	populations FLOAT
);


create table if not exists pop (
	entity_name VARCHAR(75),
	year_of_data INT,
	populations FLOAT,
	foreign key (entity_name) references demeco_entity_info(demeco_entity_name)
);

insert into pop (entity_name, year_of_data, populations)
select * 
from pop_staging_table
where entity_name in (select demeco_entity_name from demeco_entity_info)
on CONFLICT DO NOTHING; 

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- tables for additional information regarding each noc/npc
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- geographical affiliations information of the NOCs (geo_info in short)
-- use the following codes to update the noc_info table with additional information regarding each noc/npc
-- currently only the continent info for each noc/npc are included in this repo
-- may expand to include additional info such as subcontinental_regions in the future

-- create a temp table
create table if not exists geo_info (
	noc_code CHAR(3) primary key,
	noc_name VARCHAR(75),
	continent VARCHAR(20),
	subcontinental_regions VARCHAR(50),
	hemisphere VARCHAR(6),
	foreign key (noc_code) references noc_info(noc_code)
);
-- then import the database_csvs/noc_to_demeco_entity_conversion_table.csv to the table named geo_info
-- just the noc_code and the continent column 
-- for now only continent info is provided. additional geo info may be added in future updates


-- then update the noc_info table
alter table noc_info 
add column continent VARCHAR(20);

update noc_info 
set continent = geo_info.continent
from geo_info
where noc_info.noc_code = geo_info.noc_code;


-- check
select *
from noc_info
limit 10;

-- optional
drop table if exists geo_info; 
drop table if exists pop_staging_table;
drop table if exists gdp_per_capita_staging_table;

