with source as (
    select * from {{ source('raw_sources', 'region') }}
)

select 
    "SalesTerritoryKey"::int as region_sales_territory_key , 
    "Region"::varchar as region, 
    "Country"::varchar as region_country, 
    "Group"::varchar as region_group, 
    "ingested_at"::datetime as ingested_at, 
    "snapshot_date"::date as snapshot_date 
from source