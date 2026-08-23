{{ config(materialized='table') }}

with staging_data AS (
    select * from {{ ref('stg_reseller') }}
),

unique_data as (
    select 
    distinct
        staging_data."reseller_key", 
        staging_data."business_type", 
        staging_data."reseller", 
        staging_data."city", 
        staging_data."state_province", 
        staging_data."country_region",
        staging_data."ingested_at", 
        staging_data."snapshot_date"
    from staging_data
)

select 
     MD5(CONCAT_WS('|', 
        {{clean_property_text('reseller_key')}},
        {{clean_property_text('reseller')}},
        {{clean_property_text('city')}}
        )) AS dwh_reseller_id,
    business_type, 
    reseller, 
    city, 
    state_province, 
    country_region, 
    ingested_at, 
    snapshot_date 
from unique_data


