
# Exploratory Analyses

This file has the same content as the identifically named sql file (`s1_exploratory_analyses.sql`), which stores both SQL queries and their outputs for the exploratory analyses. Here, they are presented in a markdown format (instead of a sql script) for ease of visualization and navigation.

These queries aim to answer questions such as:
* Which continent won the most medals during recent editions?
* Which NOCs[^1] performed the best during recent editions?
* Which NOCs and continents performed the best during the past two Olympic cycles?
* And many more!

## 2024 Summer Games (Paris)

First create a view storing medal counts, NOC names, rankings and other NOC-related information.

```sql
drop view if exists pa2024_medals_all_nocs cascade;
create view pa2024_medals_all_nocs as
with temp as(
	select noc.noc_code, noc_name, 
	       coalesce(gold, 0) as gold, coalesce(silver, 0) as silver, coalesce(bronze, 0) as bronze
	from noc_info as noc
	left join medal_table_2024 as mt2024 on noc.noc_code = mt2024.noc_code
)
select 
	case when noc_code in ('NPA', 'RPT', 'RPC', 'AIN', 'ROC', 'OAR', 'MAC', 'FRO', 'RUS') then null
	     else rank() over(order by gold desc, silver desc, bronze desc)
	end as rankings,
	noc_code, noc_name, gold, silver, bronze,
	gold + silver + bronze as total
from temp
order by rankings, noc_name;
```
Please also see the [Notes and Comments](#notes-and-comments) for some additional details.


### The best performing teams at these games

Query:
```sql
select * from pa2024_medals_all_nocs
where rankings <= 5;
```

Output:
       
|rankings|noc_code|noc_name|gold|silver|bronze|total|
|--------|--------|--------|----|------|------|-----|
|1|USA|United States|40|44|42|126|
|2|CHN|China|40|27|24|91|
|3|JPN|Japan|20|12|13|45|
|4|AUS|Australia|18|19|16|53|
|5|FRA|France|16|26|22|64|


### The best performing teams in each continent at these games

Query:

```sql
with tmp as (
select mt2024.*, noc_info.continent,
       rank() over(partition by continent order by rankings) as continent_rank
from pa2024_medals_all_nocs as mt2024
left join noc_info on noc_info.noc_code = mt2024.noc_code)
select continent_rank, rankings as world_rank, noc_code, noc_name, continent, 
       gold, silver, bronze, total
from tmp
where continent <> '' and continent_rank <= 3 and total > 0;
```
output: 

|continent_rank|world_rank|noc_code|noc_name|continent|gold|silver|bronze|total|
|--------------|----------|--------|--------|---------|----|------|------|-----|
|1|17|KEN|Kenya|Africa|4|2|5|11|
|2|39|ALG|Algeria|Africa|2|0|1|3|
|3|44|RSA|South Africa|Africa|1|3|2|6|
|1|1|USA|United States|Americas|40|44|42|126|
|2|12|CAN|Canada|Americas|9|7|11|27|
|3|20|BRA|Brazil|Americas|3|7|10|20|
|1|2|CHN|China|Asia|40|27|24|91|
|2|3|JPN|Japan|Asia|20|12|13|45|
|3|8|KOR|Republic of Korea|Asia|13|9|10|32|
|1|5|FRA|France|Europe|16|26|22|64|
|2|6|NED|Netherlands|Europe|15|7|12|34|
|3|7|GBR|Great Britain|Europe|14|22|29|65|
|1|4|AUS|Australia|Oceania|18|19|16|53|
|2|11|NZL|New Zealand|Oceania|10|7|3|20|
|3|75|FIJ|Fiji|Oceania|0|1|0|1|


## Medals won by each continent

Query:

```sql
with tmp as (
select mt2024.*, noc_info.continent,
       sum(gold) over(partition by continent) as continent_gold,
       sum(silver) over(partition by continent) as continent_silver,
       sum(bronze) over(partition by continent) as continent_bronze,
       sum(total) over(partition by continent) as continent_total
from pa2024_medals_all_nocs as mt2024
left join noc_info on noc_info.noc_code = mt2024.noc_code
)
select continent, continent_gold, continent_silver, continent_bronze, continent_total 
from (select continent, continent_gold, continent_silver, continent_bronze, continent_total,
             row_number() over(partition by continent) as rnum
      from tmp)
where rnum = 1 and continent <> ''
order by continent_gold desc, continent_silver desc, continent_bronze desc;
```

Output:

|continent|continent_gold|continent_silver|continent_bronze|continent_total|
|---------|--------------|----------------|----------------|---------------|
|Europe|128|144|176|448|
|Asia|97|70|89|256|
|Americas|62|71|84|217|
|Oceania|28|27|19|74|
|Africa|13|15|15|43|



## 2020 Summer Games (Tokyo)

First create a view storing medal counts, NOC names, rankings and other NOC-related information.

```sql
drop view if exists tk2020_medals_all_nocs cascade;
create view tk2020_medals_all_nocs as
with temp as(
select noc.noc_code, noc_name, 
	   coalesce(gold, 0) as gold, coalesce(silver, 0) as silver, coalesce(bronze, 0) as bronze
from noc_info as noc
left join medal_table_2020 as mt2020 on noc.noc_code = mt2020.noc_code
)
select 
	case when noc_code in ('NPA', 'RPT', 'RPC', 'AIN', 'OAR', 'MAC', 'FRO', 'RUS') then null
	     else rank() over(order by gold desc, silver desc, bronze desc)
    end as rankings,
	noc_code, noc_name, gold, silver, bronze,
	(gold + silver + bronze) as total
from temp
order by rankings, noc_name;
```

### The best performing teams at these games

Query:

```sql
select * from tk2020_medals_all_nocs
where rankings <= 5;
```

Output:

|rankings|noc_code|noc_name|gold|silver|bronze|total|
|--------|--------|--------|----|------|------|-----|
|1|USA|United States|39|41|33|113|
|2|CHN|China|38|32|19|89|
|3|JPN|Japan|27|14|17|58|
|4|GBR|Great Britain|22|20|22|64|
|5|ROC|ROC|20|28|23|71|


## 2022 Winter Games (Beijing)

First create a view storing medal counts, NOC names, rankings and other NOC-related information.

```sql
drop view if exists be2022_medals_all_nocs cascade;
create view be2022_medals_all_nocs as
with temp as(
select noc.noc_code, noc_name, 
	   coalesce(gold, 0) as gold, coalesce(silver, 0) as silver, coalesce(bronze, 0) as bronze
from noc_info as noc
left join medal_table_2022 as mt2022 on noc.noc_code = mt2022.noc_code
)
select 
	case when noc_code in ('NPA', 'RPT', 'RPC', 'AIN', 'OAR', 'MAC', 'FRO', 'RUS', 'PRK') then null
	     else rank() over(order by gold desc, silver desc, bronze desc)
    end as rankings,
	noc_code, noc_name, gold, silver, bronze,
	(gold + silver + bronze) as total
from temp
order by rankings, noc_name;
```

### The best performing teams at these games

Query:

```sql
select * from be2022_medals_all_nocs
where rankings <= 5;
```

Output:

|rankings|noc_code|noc_name|gold|silver|bronze|total|
|--------|--------|--------|----|------|------|-----|
|1|NOR|Norway|16|8|13|37|
|2|GER|Germany|12|10|5|27|
|3|USA|United States|9|9|7|25|
|4|CHN|China|9|4|2|15|
|5|SWE|Sweden|8|5|5|18|


## 2018 Winter Games (Pyeongchang)

First create a view storing medal counts, NOC names, rankings and other NOC-related information.

```sql
drop view if exists pc2018_medals_all_nocs cascade;
create view pc2018_medals_all_nocs as
with temp as(
select noc.noc_code, noc_name, 
	   coalesce(gold, 0) as gold, coalesce(silver, 0) as silver, coalesce(bronze, 0) as bronze
from noc_info as noc
left join medal_table_2018 as mt2018 on noc.noc_code = mt2018.noc_code
)
select 
	case when noc_code in ('NPA', 'RPT', 'RPC', 'AIN', 'ROC', 'MAC', 'FRO', 'RUS') then null
	     else rank() over(order by gold desc, silver desc, bronze desc)
    end as rankings,
	noc_code, noc_name, gold, silver, bronze,
	(gold + silver + bronze) as total
from temp
order by rankings, noc_name;
```

### The best performing teams at these games

Query:

```sql
select * from pc2018_medals_all_nocs
where rankings <= 5;
```

Output:

|rankings|noc_code|noc_name|gold|silver|bronze|total|
|--------|--------|--------|----|------|------|-----|
|1|NOR|Norway|14|14|11|39|
|2|GER|Germany|14|10|7|31|
|3|CAN|Canada|11|8|10|29|
|4|USA|United States|9|8|6|23|
|5|NED|Netherlands|8|6|6|20|


## Recent Games (results aggregated from OGs during the past two Olympic cycles)

Performances at the OGs may fluctuate from edition to edition. So let's aggregate the results of all OGs taking place over the past two Olympic cycles to gain a better picture of their latest sporting strength.

First create a view storing medal counts, NOC names, rankings and other NOC-related information.

```sql
drop view if exists recent_games_medals cascade;
create view recent_games_medals as 
with tmp as (
select mt2024.noc_code as noc_code, noc_info.noc_name,
	   mt2024.gold + mt2020.gold + mt2022.gold + mt2018.gold as gold_total,
	   mt2024.silver + mt2020.silver + mt2022.silver + mt2018.silver as silver_total,
	   mt2024.bronze + mt2020.bronze + mt2022.bronze + mt2018.bronze as bronze_total
from pa2024_medals_all_nocs as mt2024
full join tk2020_medals_all_nocs as mt2020 on mt2020.noc_code = mt2024.noc_code
full join be2022_medals_all_nocs as mt2022 on mt2022.noc_code = mt2024.noc_code
full join pc2018_medals_all_nocs as mt2018 on mt2018.noc_code = mt2024.noc_code
left join noc_info on mt2024.noc_code = noc_info.noc_code
)
select 
	case when noc_code in ('NPA', 'RPC', 'RPT', 'AIN', 'MAC', 'FRO', 'RUS') then null
	     else rank() over(order by gold_total desc, silver_total desc, bronze_total desc) 
	end as rankings, noc_code, noc_name, gold_total, silver_total, bronze_total, 
	(gold_total + silver_total + bronze_total) as total
from tmp
order by gold_total desc, silver_total desc, bronze_total desc;
```

### The best performing teams during the past two OG cycles

Query:

```sql
select * from recent_games_medals
where rankings <= 10;
```

Output:

|rankings|noc_code|noc_name|gold_total|silver_total|bronze_total|total|
|--------|--------|--------|----------|------------|------------|-----|
|1|USA|United States|97|102|88|287|
|2|CHN|China|88|69|47|204|
|3|JPN|Japan|54|38|42|134|
|4|GER|Germany|48|44|36|128|
|5|NED|Netherlands|41|30|36|107|
|6|GBR|Great Britain|38|43|55|136|
|7|NOR|Norway|38|25|29|92|
|8|FRA|France|36|49|41|126|
|9|AUS|Australia|36|30|40|106|
|10|CAN|Canada|31|30|45|106|



### The best performing teams in each continent during the past two cycles

Query:

```sql
with tmp as (
select rgm.*, noc_info.continent,
       rank() over(partition by continent order by rankings) as continent_rank
from recent_games_medals as rgm
left join noc_info on noc_info.noc_code = rgm.noc_code)
select continent_rank, rankings as world_rank, noc_code, noc_name, continent, 
       gold_total, silver_total, bronze_total, total
from tmp
where continent <> '' and continent_rank <= 5 and total > 0;
```

Output:

 |continent_rank|world_rank|noc_code|noc_name|continent|gold_total|silver_total|bronze_total|total|
|--------------|----------|--------|--------|---------|----------|------------|------------|-----|
|1|24|KEN|Kenya|Africa|8|6|7|21|
|2|47|UGA|Uganda|Africa|3|2|1|6|
|3|52|RSA|South Africa|Africa|2|5|2|9|
|4|53|ETH|Ethiopia|Africa|2|4|2|8|
|5|56|EGY|Egypt|Africa|2|2|5|9|
|1|1|USA|United States|Americas|97|102|88|287|
|2|10|CAN|Canada|Americas|31|30|45|106|
|3|20|BRA|Brazil|Americas|10|13|18|41|
|4|22|CUB|Cuba|Americas|9|4|11|24|
|5|36|JAM|Jamaica|Americas|5|4|6|15|
|1|2|CHN|China|Asia|88|69|47|204|
|2|3|JPN|Japan|Asia|54|38|42|134|
|3|12|KOR|Republic of Korea|Asia|26|26|26|78|
|4|19|UZB|Uzbekistan|Asia|11|2|5|18|
|5|28|IRI|IR Iran|Asia|6|8|5|19|
|1|4|GER|Germany|Europe|48|44|36|128|
|2|5|NED|Netherlands|Europe|41|30|36|107|
|3|6|GBR|Great Britain|Europe|38|43|55|136|
|4|7|NOR|Norway|Europe|38|25|29|92|
|5|8|FRA|France|Europe|36|49|41|126|
|1|9|AUS|Australia|Oceania|36|30|40|106|
|2|15|NZL|New Zealand|Oceania|19|14|12|45|
|3|70|FIJ|Fiji|Oceania|1|1|1|3|

### The total number of medals won by each continent during the past two cycles

Query:

```sql
with tmp as (
select rgm.*, noc_info.continent,
       sum(gold_total) over(partition by continent) as continent_gold,
       sum(silver_total) over(partition by continent) as continent_silver,
       sum(bronze_total) over(partition by continent) as continent_bronze,
       sum(total) over(partition by continent) as continent_total
from recent_games_medals as rgm
left join noc_info on noc_info.noc_code = rgm.noc_code
)
select continent, continent_gold, continent_silver, continent_bronze, continent_total 
from (select continent, continent_gold, continent_silver, continent_bronze, continent_total,
             row_number() over(partition by continent) as rnum
      from tmp)
where rnum = 1 and continent <> ''
order by continent_gold desc, continent_silver desc, continent_bronze desc;
```

Output:

|continent|continent_gold|continent_silver|continent_bronze|continent_total|
|---------|--------------|----------------|----------------|---------------|
|Europe|427|454|527|1408|
|Asia|207|176|197|580|
|Americas|166|170|190|526|
|Oceania|56|45|53|154|
|Africa|24|31|30|85|

## Notes and Comments

You may notice that several NOCs were excluded from ranking in this script. This may be due to one of several reasons:
* NPA, RPC, RPT, MAC, and FRO are delegations specific to the paralympics and therefore are not included in the rankings
* Some delegations (e.g. RUS, ROC, etc.) were prevented from participating at some of the editions analyzed here and were unranked for the editions in which these delegations were prevented from participating
* AIN athletes competed in their individual capacity and therefore are not ranked as a delegation either

[^1]: NOCs = National Olympic Committees

