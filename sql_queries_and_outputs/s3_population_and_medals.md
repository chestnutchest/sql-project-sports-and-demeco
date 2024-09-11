# Medal Performances and Population Sizes

This file has the same content as the identifically named md file (`s3_population_analysis.sql`), which stores both SQL queries and their outputs for the population-related analyses. 
Here, they are presented in a markdown format (instead of a sql script) for ease of visualization and navigation.

These queries aim to answer questions such as
- What are the least populous countries/territories that won at least one medal during recent editions?
- Which countries/territories have the highest number of medals per million people?
- And many more!


## 2024 Summer Games (Paris)
First, create a view storing medal counts, NOC names, and associated population data

```sql
drop view if exists pa2024_medals_pop;
create view pa2024_medals_pop as
with temp as(
    select mt2024.noc_code, dei.noc_name, dei.demeco_entity_name, 
	       gold, silver, bronze, total,
	       pop.populations, pop.year_of_data, 
	       row_number() over(partition by mt2024.noc_name order by pop.year_of_data desc) as year_rank
    from pa2024_medals_all_nocs as mt2024
    left join demeco_entity_info as dei on mt2024.noc_code = dei.noc_code
    left join pop on dei.demeco_entity_name = pop.entity_name
)
select *, (total/populations)*1000000 as medal_per_million, (gold/populations)*1000000 as gold_per_million 
from temp
where year_of_data = 2024 and populations is not null and noc_code not in ('NPA', 'RPT', 'RPC', 'AIN', 'ROC', 'OAR', 'MAC', 'FRO', 'RUS', 'BLR')
order by populations desc;
```

### Countries/territories with the highest number of medals per million people at these games

Query:
```sql
select noc_code, noc_name, 
       to_char(populations, '9999999999') as populations, 
       to_char(medaL_per_million, '9999.99') as medal_per_million, 
       gold, silver, bronze, total 
from pa2024_medals_pop
order by medal_per_million desc
limit 5;
```

Output:
|noc_code|noc_name|populations|medal_per_million|gold|silver|bronze|total|
|--------|--------|-----------|-----------------|----|------|------|-----|
|GRN|Grenada|     117216|   17.06|0|0|2|2|
|DMA|Dominica|      66224|   15.10|1|0|0|1|
|LCA|Saint Lucia|     179751|   11.13|1|1|0|2|
|NZL|New Zealand|    5213946|    3.84|10|7|3|20|
|BRN|Bahrain|    1607060|    2.49|2|1|1|4|


### Countries/territories with the highest number of gold medals per million people at these games

Query:
```sql
select noc_code, noc_name, 
       to_char(populations, '9999999999') as populations, 
       to_char(gold_per_million, '9999.99') as gold_per_million, 
       gold, silver, bronze, total 
from pa2024_medals_pop
order by gold_per_million desc
limit 5;
```

Output:
|noc_code|noc_name|populations|gold_per_million|gold|silver|bronze|total|
|--------|--------|-----------|----------------|----|------|------|-----|
|DMA|Dominica|      66224|   15.10|1|0|0|1|
|LCA|Saint Lucia|     179751|    5.56|1|1|0|2|
|NZL|New Zealand|    5213946|    1.92|10|7|3|20|
|BRN|Bahrain|    1607060|    1.24|2|1|1|4|
|SLO|Slovenia|    2118690|     .94|2|1|0|3|


### The most populous countries/territories that failed to win at least one medal at these games

Query:
```sql
select noc_code, noc_name, to_char(populations, '9999999999') as populations, gold, silver, bronze, total
from pa2024_medals_pop
where total = 0
order by populations desc
limit 5;
```

Output:
|noc_code|noc_name|populations|gold|silver|bronze|total|
|--------|--------|-----------|----|------|------|-----|
|NGR|Nigeria|  232679482|0|0|0|0|
|BAN|Bangladesh|  173562367|0|0|0|0|
|COD|Democratic Republic of the Congo|  109276265|0|0|0|0|
|VIE|Vietnam|  100987686|0|0|0|0|
|TAN|United Republic of Tanzania|   68560162|0|0|0|0|


### The most populous countries/territories that failed to win at least one gold medal at these games

```sql
select noc_code, noc_name, to_char(populations, '9999999999') as populations, gold, silver, bronze, total
from pa2024_medals_pop
where gold = 0
order by populations desc
limit 5;
```
|noc_code|noc_name|populations|gold|silver|bronze|total|
|--------|--------|-----------|----|------|------|-----|
|IND|India| 1450935779|0|1|5|6|
|NGR|Nigeria|  232679482|0|0|0|0|
|BAN|Bangladesh|  173562367|0|0|0|0|
|MEX|Mexico|  130860999|0|3|2|5|
|COD|Democratic Republic of the Congo|  109276265|0|0|0|0|



### The least populous countries/territories that won at least one medal at these games

Query:
```sql
select noc_code, noc_name, to_char(populations, '9999999999') as populations, gold, silver, bronze, total
from pa2024_medals_pop
where total > 0
order by populations 
limit 5;
```

Output: 
|noc_code|noc_name|populations|gold|silver|bronze|total|
|--------|--------|-----------|----|------|------|-----|
|DMA|Dominica|      66224|1|0|0|1|
|GRN|Grenada|     117216|0|0|2|2|
|LCA|Saint Lucia|     179751|1|1|0|2|
|CPV|Cabo Verde|     524877|0|0|1|1|
|FIJ|Fiji|     928802|0|1|0|1|


### The least populous countries/territories that won at least one gold medal at these games

Query:
```sql
select noc_code, noc_name, to_char(populations, '9999999999') as populations, gold, silver, bronze, total
from pa2024_medals_pop
where gold > 0
order by populations 
limit 5;
```

Output:
|noc_code|noc_name|populations|gold|silver|bronze|total|
|--------|--------|-----------|----|------|------|-----|
|DMA|Dominica|      66224|1|0|0|1|
|LCA|Saint Lucia|     179751|1|1|0|2|
|BRN|Bahrain|    1607060|2|1|1|4|
|SLO|Slovenia|    2118690|2|1|0|3|
|BOT|Botswana|    2521145|1|1|0|2|


## Recent Games (aggregated results of all OGs during the past two Olympic cycles)

Performances at the OGs may fluctuate from edition to edition. So let's aggregate the results of all OGs taking place over the past two Olympic cycles to gain a better picture of their latest sporting strength.

First, create a view storing medal counts aggregating all OGs over the past two cycles, NOC names, and associated population sizes.


```sql
drop view if exists recent_games_medals_pop;
create view recent_games_medals_pop as
with temp as(
    select rgmt.noc_code, dei.noc_name, dei.demeco_entity_name, 
	       gold_total, silver_total, bronze_total, total,
	       pop.populations, pop.year_of_data, 
	       row_number() over(partition by rgmt.noc_code order by pop.year_of_data desc) as year_rank
    from recent_games_medals as rgmt
    left join demeco_entity_info as dei on rgmt.noc_code = dei.noc_code
    left join pop on dei.demeco_entity_name = pop.entity_name
)
select *, (total/populations)*1000000 as medal_per_million, (gold_total/populations)*1000000 as gold_per_million
from temp
where year_of_data = 2024 and populations is not null
	  and noc_code not in ('NPA', 'RPT', 'RPC', 'AIN', 'MAC', 'FRO', 'RUS')
order by medal_per_million desc;
```

### Countries/territories with the highest number of gold medals per million people during the past two cycles

Query:
```sql
select noc_code, noc_name, 
       to_char(populations, '9999999999') as populations, 
       to_char(gold_per_million, '9999.99') as gold_per_million, 
       gold_total, silver_total, bronze_total, 
       total as medal_total
from recent_games_medals_pop
where total > 0
order by gold_per_million desc
limit 5;
```

Output:
|noc_code|noc_name|populations|gold_per_million|gold_total|silver_total|bronze_total|medal_total|
|--------|--------|-----------|----------------|----------|------------|------------|-----------|
|BER|Bermuda|      64658|   15.47|1|0|0|1|
|DMA|Dominica|      66224|   15.10|1|0|0|1|
|NOR|Norway|    5576655|    6.81|38|25|29|92|
|LCA|Saint Lucia|     179751|    5.56|1|1|0|2|
|BAH|Bahamas|     401281|    4.98|2|0|0|2|


### Countries/territories with the highest number of medals per million population during the past two cycles

```sql
select noc_code, noc_name, 
       to_char(populations, '9999999999') as populations, 
       to_char(medaL_per_million, '9999.99') as medal_per_million, 
       gold_total, silver_total, bronze_total, 
       total as medal_total
from recent_games_medals_pop
where total > 0
order by medal_per_million desc
limit 5;
```

Ouptuts:
|noc_code|noc_name|populations|medal_per_million|gold_total|silver_total|bronze_total|medal_total|
|--------|--------|-----------|-----------------|----------|------------|------------|-----------|
|SMR|San Marino|      33606|   89.27|0|1|2|3|
|GRN|Grenada|     117216|   25.59|0|0|3|3|
|LIE|Liechtenstein|      39894|   25.07|0|0|1|1|
|NOR|Norway|    5576655|   16.50|38|25|29|92|
|BER|Bermuda|      64658|   15.47|1|0|0|1|


### The most populous countries/territories that failed to win at least one medal over the past two cycles

Query:
```sql
select noc_code, noc_name, populations, 
       gold_total, silver_total, bronze_total, total as medal_total
from recent_games_medals_pop
where total = 0
order by populations desc
limit 5;
```

Output:
|noc_code|noc_name|populations|gold_total|silver_total|bronze_total|medal_total|
|--------|--------|-----------|----------|------------|------------|-----------|
|BAN|Bangladesh|173562367|0|0|0|0|
|COD|Democratic Republic of the Congo|109276265|0|0|0|0|
|VIE|Vietnam|100987686|0|0|0|0|
|TAN|United Republic of Tanzania|68560162|0|0|0|0|
|MYA|Myanmar|54500087|0|0|0|0|


### The most populous countries/territories that failed to win at least one gold medal over the past two cycles

Query:
```sql
select noc_code, noc_name, to_char(populations, '9999999999') as populations, 
       gold_total, silver_total, bronze_total, total as medal_total
from recent_games_medals_pop
where gold_total = 0
order by populations desc
limit 5;
```

Output:
|noc_code|noc_name|populations|gold_total|silver_total|bronze_total|medal_total|
|--------|--------|-----------|----------|------------|------------|-----------|
|NGR|Nigeria|  232679482|0|1|1|2|
|BAN|Bangladesh|  173562367|0|0|0|0|
|MEX|Mexico|  130860999|0|3|6|9|
|COD|Democratic Republic of the Congo|  109276265|0|0|0|0|
|VIE|Vietnam|  100987686|0|0|0|0|


### The least populous countries/territories that won at least one medal over the past two cycles

Query:
```sql
select noc_code, noc_name, to_char(populations, '9999999999') as populations, 
       gold_total, silver_total, bronze_total, 
       total as medal_total
from recent_games_medals_pop
where total > 0
order by populations
limit 5;
```

Output:
|noc_code|noc_name|populations|gold_total|silver_total|bronze_total|medal_total|
|--------|--------|-----------|----------|------------|------------|-----------|
|SMR|San Marino|      33606|0|1|2|3|
|LIE|Liechtenstein|      39894|0|0|1|1|
|BER|Bermuda|      64658|1|0|0|1|
|DMA|Dominica|      66224|1|0|0|1|
|GRN|Grenada|     117216|0|0|3|3|



### The least populous countries/territories that won at least one gold medal over the past two cycles

Query:
```sql
select noc_code, noc_name, to_char(populations, '9999999999') as populations, 
       gold_total, silver_total, bronze_total, 
       total as medal_total
from recent_games_medals_pop
where gold_total > 0
order by populations
limit 5;
```

Output:
|noc_code|noc_name|populations|gold_total|silver_total|bronze_total|medal_total|
|--------|--------|-----------|----------|------------|------------|-----------|
|BER|Bermuda|      64658|1|0|0|1|
|DMA|Dominica|      66224|1|0|0|1|
|LCA|Saint Lucia|     179751|1|1|0|2|
|BAH|Bahamas|     401281|2|0|0|2|
|FIJ|Fiji|     928802|1|1|1|3|





