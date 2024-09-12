# Database CSV files Documentation

The csv files in this folder have been processed with pandas in Python and were imported into a PostgreSQL database for analysis.

This documentation provides an overview of the information stored in each csv file and detailed descriptions of each of their columns. The data sources are also provided where appropriate.

For information on which SQL tables these files should be imported into, please consult [schema.sql](../schema.sql).

## List of abbreviations/acronyms that you may encounter 

demeco - demographic and economic \
pop - population \
GDP - gross domestic product \
OG - Olympic Games \
NOC - National Olympic Committee \
NPC - National Paralympic Committee 

## Name conversion tables

The following two tables provide name mapping information. The NOC names used in the [OG datasets](#og-related-files) do not necessarily follow the same naming convention as the [demeco datasets](#demeco-datasets-related-files). For example, the Republic of Cabo Verde is referred to as "Cabo Verde" in the OG datasets and as "Cape Verde" in the demeco datasets. The following tables allow names in the OG datasets to be mapped to entity names used in the demeco dataset, and vice versa. 

- `demeco_entity_to_noc_conversion_table.csv`: 
    - `demeco_entity_name`: the names of the geographical entity used in the demeco dataset
    - `noc_npc_code`: a three-letter code that uniquely identifies each NOC or NPC
    - `noc_npc_name`: the name of the corresponding NOC/NPC. 
    - `continent`: the continent to which the NOC/NPC belongs. This is largely based on continental affiliation in international sports federations rather than strictly geographical proximity.


- `noc_to_demeco_entity_conversion_table.csv`: 
    - `noc_npc_code`: a three-letter code that uniquely identifies each NOC or NPC
    - `noc_npc_name`: the name of the NOC/NPC 
    - `demeco_matched_name`: the name of the corresponding geographical entity used in the demeco datasets
    - `continent`: the continent to which the NOC/NPC belongs. This is largely based on continental affiliation in international sports federations rather than strictly geographical proximity.

## OG-related files

The OG medal counts were collected from relevant OG medal table pages on [Wikipedia](https://www.wikipedia.org). NOC names provided by Wikipedia have been matched to the `noc_code` in the tables above.

- `medal_table_20**_o.csv`: medal table for the OG indicated in the file name, e.g. `medal_table_2020_o.csv` stores the counts of the Tokyo games.
    - `noc_code`: the NOC code
    - `gold`: number of gold medals won at these games
    - `silver`: number of silver medals won at these games
    - `bronze`: number of bronze medals won at these games


## DEMECO datasets-related files

Unless otherwise stated, the demeco datasets were retrieved from [ourworldindata.org](https://www.ourworldindata.org). Some of the demeco datasets stored in this repo have been further processed to retain information related to the questions investigated by this project. This means certain information present in the original ourworldindata.org version unrelated to the project, such as data from earlier years or projections for future years, have been removed. The datasets have also be reformated to be compatible with the SQL query scripts.

- `gdp_per_capita.csv`: GDP per capita data
    - `entity_name`: name of the geographical entity
    - `year`: year to which the data point correponds 
    - `gdp_per_capita`: the GDP per capita value, expressed in 2017 international dollar. The values shown here have been rounded to the nearest integer.
    - `origin`: source of data. `pw`: data processed by ourworldindata.org based on Penn World Table data, [link to data source](https://ourworldindata.org/grapher/gdp-per-capita-penn-world-table); `wb`: data processed by ourworldindata.org based on World Bank data, [link to data source](https://ourworldindata.org/grapher/gdp-per-capita-worldbank); `other-estimated`: estimated based on other information

- `populations.csv`: population data
  - `entity_name`: name of the geographical entity
  - `year`: year to which the data point correponds 
  - `population`: population size

The population data were compiled and processed by ourworldindata.org based on UN estimates and projections, [link to data source](https://ourworldindata.org/grapher/population-with-un-projections).

