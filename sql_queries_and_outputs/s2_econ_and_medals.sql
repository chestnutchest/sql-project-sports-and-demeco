-- Medal Performances and GDP per capita
/*
This file has the same content as the identifically named md file (`s2_econ_and_medals.md`), which stores both SQL queries and their outputs for the GDP per capita-related analyses. 
In the md file, they are presented in a markdown format (instead of a sql script) for ease of visualization and navigation.

These queries aim to answer questions such as
- What are the countries/territories with highest GDP per capita that failed to win any medals during?
- and many more!

Please note that all GDP per capita data here are expressed in the 2017 value of the international dollar

*/

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 2024 summer games (Paris)
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- First, create a view storing medal counts, NOC names, and associated GDP per capita values.

drop view if exists pa2024_medals_gdppc;
create view pa2024_medals_gdppc as
with temp as(
    select mt2024.noc_code, dei.noc_name, dei.demeco_entity_name, 
	       gold, silver, bronze, total,
	       gpc.gdp_per_capita_val, gpc.year_of_data, 
	       row_number() over(partition by mt2024.noc_name order by gpc.year_of_data desc) as year_rank
    from pa2024_medals_all_nocs as mt2024
    left join demeco_entity_info as dei on mt2024.noc_code = dei.noc_code
    left join gdp_per_capita as gpc on dei.demeco_entity_name = gpc.entity_name
)
select * from temp
where year_rank = 1 and gdp_per_capita_val is not null
order by gdp_per_capita_val desc;

-- countries/territories with highest GDP per capita among those that failed to win at least one medal at these games
select noc_code, noc_name, gdp_per_capita_val as gdp_per_capita, gold, silver, bronze, total
from pa2024_medals_gdppc
where gdp_per_capita_val is not null and total = 0
order by gdp_per_capita_val desc 
limit 5;

/*
|noc_code|noc_name|gdp_per_capita|gold|silver|bronze|total|
|--------|--------|--------------|----|------|------|-----|
|MON|Monaco|224670|0|0|0|0|
|LIE|Liechtenstein|174678|0|0|0|0|
|LUX|Luxembourg|117747|0|0|0|0|
|BER|Bermuda|81166|0|0|0|0|
|UAE|United Arab Emirates|74918|0|0|0|0|
 */

-- countries/territories with highest GDP per capita among those that failed to win at least one gold medal at these games
select noc_code, noc_name, gdp_per_capita_val, gold, silver, bronze, total
from pa2024_medals_gdppc
where gdp_per_capita_val is not null and gold = 0 
order by gdp_per_capita_val desc 
limit 5;

/*
|noc_code|noc_name|gdp_per_capita_val|gold|silver|bronze|total|
|--------|--------|------------------|----|------|------|-----|
|MON|Monaco|224670|0|0|0|0|
|LIE|Liechtenstein|174678|0|0|0|0|
|LUX|Luxembourg|117747|0|0|0|0|
|SGP|Singapore|108036|0|0|1|1|
|QAT|Qatar|96558|0|0|1|1|
 */

-- countries/territories with lowest gdp per capita among those that won at least one gold medal at these games
select noc_code, noc_name, gdp_per_capita_val, gold, silver, bronze, total
from pa2024_medals_gdppc
where gdp_per_capita_val is not null and gold > 0
order by gdp_per_capita_val
limit 5;

/*
|noc_code|noc_name|gdp_per_capita_val|gold|silver|bronze|total|
|--------|--------|------------------|----|------|------|-----|
|UGA|Uganda|2280|1|1|0|2|
|ETH|Ethiopia|2381|1|3|0|4|
|KEN|Kenya|4882|4|2|5|11|
|PAK|Pakistan|5377|1|0|0|1|
|UZB|Uzbekistan|8073|8|2|3|13|

 */

-- countries/territories with lowest gdp per capita among those that won at least one medal at these games
select noc_code, noc_name, gdp_per_capita_val, gold, silver, bronze, total
from pa2024_medals_gdppc
where gdp_per_capita_val is not null and total > 0
order by gdp_per_capita_val
limit 5;

/*
|noc_code|noc_name|gdp_per_capita_val|gold|silver|bronze|total|
|--------|--------|------------------|----|------|------|-----|
|PRK|Democratic People's Republic of Korea|2050|0|2|4|6|
|UGA|Uganda|2280|1|1|0|2|
|ETH|Ethiopia|2381|1|3|0|4|
|ZAM|Zambia|3366|0|0|1|1|
|TJK|Tajikistan|4137|0|0|3|3|

 */

-- countries/territories with highest gold medal to gdp per capita ratio 
-- i.e. how many gold medals can you get per 1000 dollars in GDP per capita?
select noc_code, noc_name, 
	   to_char((gold/gdp_per_capita_val)*1000, '9999.999') as gold_to_gdppc,
	   gold, silver, bronze, total
from pa2024_medals_gdppc
where gdp_per_capita_val is not null and total > 0
order by gold_to_gdppc desc
limit 5;

/*
|noc_code|noc_name|gold_to_gdppc|gold|silver|bronze|total|
|--------|--------|-------------|----|------|------|-----|
|CHN|China|    2.199|40|27|24|91|
|UZB|Uzbekistan|     .991|8|2|3|13|
|KEN|Kenya|     .819|4|2|5|11|
|USA|United States|     .619|40|44|42|126|
|JPN|Japan|     .478|20|12|13|45|
 */

-- countries/territories with highest medal to gdp per capita ratio 
-- i.e. how many medals can you get per 1000 int. dollars in GDP per capita?
select noc_code, noc_name, 
	   to_char((total/gdp_per_capita_val)*1000, '9999.999') as medal_to_gdppc,
	   gold, silver, bronze, total
from pa2024_medals_gdppc
where gdp_per_capita_val is not null and total > 0
order by medal_to_gdppc desc
limit 5;

/*
|noc_code|noc_name|medal_to_gdppc|gold|silver|bronze|total|
|--------|--------|--------------|----|------|------|-----|
|CHN|China|    5.003|40|27|24|91|
|PRK|Democratic People's Republic of Korea|    2.927|0|2|4|6|
|KEN|Kenya|    2.253|4|2|5|11|
|USA|United States|    1.950|40|44|42|126|
|ETH|Ethiopia|    1.680|1|3|0|4|
 */


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 2020 Summer Games (Tokyo)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
drop view if exists tk2020_medals_gdppc;
create view tk2020_medals_gdppc as 
with temp as(
    select mt2020.noc_code, dei.noc_name, dei.demeco_entity_name, 
	       gold, silver, bronze, total,
	       gpc.gdp_per_capita_val, gpc.year_of_data,
	       row_number() over(partition by mt2020.noc_name order by gpc.year_of_data desc) as year_rank
    from tk2020_medals_all_nocs as mt2020
    left join demeco_entity_info as dei on mt2020.noc_code = dei.noc_code
    left join gdp_per_capita as gpc on dei.demeco_entity_name = gpc.entity_name)
select *
from temp
where year_rank = 1 and gdp_per_capita_val is not null
order by gdp_per_capita_val desc;


-- countries/territories with highest GDP per capita among those that failed to win at least one medal at these games
select noc_code, noc_name, gdp_per_capita_val, gold, silver, bronze, total
from tk2020_medals_gdppc
where gdp_per_capita_val is not null and total = 0
order by gdp_per_capita_val desc 
limit 5;

/*
|noc_code|noc_name|gdp_per_capita_val|gold|silver|bronze|total|
|--------|--------|------------------|----|------|------|-----|
|MON|Monaco|224670|0|0|0|0|
|LIE|Liechtenstein|174678|0|0|0|0|
|LUX|Luxembourg|117747|0|0|0|0|
|SGP|Singapore|108036|0|0|0|0|
|UAE|United Arab Emirates|74918|0|0|0|0|
 */

-- countries/territories with lowest gdp per capita among those that won at least one medal at these games
select noc_code, noc_name, gdp_per_capita_val, gold, silver, bronze, total
from tk2020_medals_gdppc
where gdp_per_capita_val is not null and total > 0
order by gdp_per_capita_val
limit 5;

/*
|noc_code|noc_name|gdp_per_capita_val|gold|silver|bronze|total|
|--------|--------|------------------|----|------|------|-----|
|BUR|Burkina Faso|2159|0|0|1|1|
|UGA|Uganda|2280|2|1|1|4|
|ETH|Ethiopia|2381|1|1|2|4|
|KEN|Kenya|4882|4|4|2|10|
|NGR|Nigeria|4963|0|1|1|2|
 */


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Recent Games (aggregated results of all OGs over the past two Olympic Cycle)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Performances at the OGs may fluctuate from edition to edition. 
-- So let's aggregate the results of all OGs taking place over the past two Olympic cycles 
-- to gain a better picture of their latest sporting strength.


-- First, create a view storing medal counts aggregating all OGs over the past two cycles, NOC names, and associated GDP per capita values.

drop view if exists recent_games_medals_gdppc;
create view recent_games_medals_gdppc as
with temp as(
    select rgmt.noc_code, dei.noc_name, dei.demeco_entity_name, 
	       gold_total, silver_total, bronze_total, total,
	       gpc.gdp_per_capita_val as gpc, gpc.year_of_data, 
	       row_number() over(partition by rgmt.noc_code order by gpc.year_of_data desc) as year_rank
    from recent_games_medals as rgmt
    left join demeco_entity_info as dei on rgmt.noc_code = dei.noc_code
    left join gdp_per_capita as gpc on dei.demeco_entity_name = gpc.entity_name
)
select *
from temp
where year_rank = 1 and gpc is not null;

-- countries/territories with highest GDP per capita among those that failed to win at least one medal over the past two cycles
select noc_code, noc_name, gpc as gdp_per_capita, gold_total, silver_total, bronze_total, total
from recent_games_medals_gdppc
where gpc is not null and total = 0
order by gdp_per_capita desc 
limit 5;

/*
|noc_code|noc_name|gdp_per_capita|gold_total|silver_total|bronze_total|total|
|--------|--------|--------------|----------|------------|------------|-----|
|MON|Monaco|224670|0|0|0|0|
|LUX|Luxembourg|117747|0|0|0|0|
|UAE|United Arab Emirates|74918|0|0|0|0|
|CAY|Cayman Islands|71354|0|0|0|0|
|BRU|Brunei Darussalam|58670|0|0|0|0|
 */

-- countries/territories with highest GDP per capita among those that failed to win at least one gold medal at these games
select noc_code, noc_name, gpc as gdp_per_capita, gold_total, silver_total, bronze_total, total
from recent_games_medals_gdppc
where gpc is not null and gold_total = 0
order by gdp_per_capita desc 
limit 5;

/*
|noc_code|noc_name|gdp_per_capita|gold_total|silver_total|bronze_total|total|
|--------|--------|--------------|----------|------------|------------|-----|
|MON|Monaco|224670|0|0|0|0|
|LIE|Liechtenstein|174678|0|0|1|1|
|LUX|Luxembourg|117747|0|0|0|0|
|SGP|Singapore|108036|0|0|1|1|
|UAE|United Arab Emirates|74918|0|0|0|0|

 */

-- countries/territories with lowest gdp per capita among those that won at least one gold medal at these games
select noc_code, noc_name, gpc as gdp_per_capita, gold_total, silver_total, bronze_total, total
from recent_games_medals_gdppc
where gpc is not null and gold_total > 0
order by gdp_per_capita
limit 5;

/*
|noc_code|noc_name|gdp_per_capita|gold_total|silver_total|bronze_total|total|
|--------|--------|--------------|----------|------------|------------|-----|
|UGA|Uganda|2280|3|2|1|6|
|ETH|Ethiopia|2381|2|4|2|8|
|KEN|Kenya|4882|8|6|7|21|
|PAK|Pakistan|5377|1|0|0|1|
|IND|India|7112|1|3|9|13|
 */

-- countries/territories with lowest gdp per capita among those that won at least one medal at these games
select noc_code, noc_name, gpc as gdp_per_capita, gold_total, silver_total, bronze_total, total
from recent_games_medals_gdppc
where gpc is not null and total > 0
order by gdp_per_capita
limit 5;

/*
|noc_code|noc_name|gdp_per_capita|gold_total|silver_total|bronze_total|total|
|--------|--------|--------------|----------|------------|------------|-----|
|PRK|Democratic People's Republic of Korea|2050|0|2|4|6|
|BUR|Burkina Faso|2159|0|0|1|1|
|UGA|Uganda|2280|3|2|1|6|
|ETH|Ethiopia|2381|2|4|2|8|
|ZAM|Zambia|3366|0|0|1|1|
 */

-- countries/territories with highest gold medal to gdp per capita ratio 
-- i.e. how many gold medals can you get per 1000 int. dollars in GDP per capita?
select noc_code, noc_name, 
	   to_char((gold_total/gpc)*1000, '9999.999') as gold_to_gdppc_ratio,
	   gold_total, silver_total, bronze_total, total
from recent_games_medals_gdppc
where gpc is not null and gold_total > 0
order by gold_to_gdppc_ratio desc
limit 5;

/*
|noc_code|noc_name|gold_to_gdppc_ratio|gold_total|silver_total|bronze_total|total|
|--------|--------|-------------------|----------|------------|------------|-----|
|CHN|China|    4.838|88|69|47|204|
|KEN|Kenya|    1.639|8|6|7|21|
|USA|United States|    1.501|97|102|88|287|
|UZB|Uzbekistan|    1.363|11|2|5|18|
|UGA|Uganda|    1.316|3|2|1|6|
 */

-- countries/territories with highest medal to gdp per capita ratio 
-- i.e. how many medals can you get per 1000 int dollars in GDP per capita?
select noc_code, noc_name, 
	   to_char((total/gpc)*1000, '9999.999') as medal_to_gdppc_ratio,
	   gold_total, silver_total, bronze_total, total
from recent_games_medals_gdppc
where gpc is not null and total > 0
order by medal_to_gdppc_ratio desc
limit 5;

/*
|noc_code|noc_name|medal_to_gdppc_ratio|gold_total|silver_total|bronze_total|total|
|--------|--------|--------------------|----------|------------|------------|-----|
|CHN|China|   11.216|88|69|47|204|
|USA|United States|    4.441|97|102|88|287|
|KEN|Kenya|    4.302|8|6|7|21|
|ETH|Ethiopia|    3.360|2|4|2|8|
|JPN|Japan|    3.203|54|38|42|134|
*/


