# Results Folder Overview

This folder stores the data analysis SQL queries and their outputs. 

**Key SQL concepts applied in these analyses:** nested queries, CTE, subqueries, window functions, joins, views, aggregate functions, filtering, conditionals

Currently there are three sets of analysis:
* `s1_exploratory_analyses.*` Exploratory analyses (e.g. who are the best performing teams, which continent won the most medals)
* `s2_econ_and_medals.*`: GDP per capita analysis
* `s3_population_and_medals.*`: Population analysis

Each analysis set is saved in two different formats `.sql` and `.md`. For example, the population analysis-related queries and outputs are stored in both `s3_population_and_medals.md` and `s3_population_and_medals.sql`. They both have the same content, including both SQL queries and their outputs. The `.sql` files are intended to be executed by a PostgreSQL-compatible program. The `.md` files present the same info in a markdown format for ease of navigation and visualization.

