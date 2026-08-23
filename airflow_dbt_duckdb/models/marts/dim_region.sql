{{ config(materialized='table') }}

with staging_data as (
    select * from {{ ref('stg_region') }}
),
unique_data AS (
    select 
        distinct 
            region_sales_territory_key, 
            region, 
            region_country, 
            region_group, 
            ingested_at, 
            snapshot_date
    from staging_data
)

select 
    MD5(concat_ws('|', 
        {{clean_property_text('region_sales_territory_key')}},
        {{clean_property_text('region_country')}},
        {{clean_property_text('region_group')}},
        {{clean_property_text('region')}}
        )) as dwh_dim_region_id,
    region, 
    region_country, 
    region_group, 
    ingested_at, 
    snapshot_date
from unique_data