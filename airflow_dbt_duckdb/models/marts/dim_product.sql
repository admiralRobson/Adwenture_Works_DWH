{{ config(materialized='table') }}

with staging_data as (
    select * from {{ ref('stg_product') }}
),
unique_data as (
select 
    distinct 
        product_key, 
        product, 
        standard_cost, 
        color, 
        subcategory, 
        category, 
        ingested_at,
        snapshot_date 
from staging_data 
) 
select 
    md5(concat_ws('|', 
        {{clean_property_text('product_key')}},
        {{clean_property_text('product')}},
        {{clean_property_text('color')}}
        )) as dwh_dim_product_id, 
    product, 
    product_key,
    {{clean_varchar_to_decimal('standard_cost')}} as standard_cost,
    color, 
    subcategory, 
    category, 
    ingested_at, 
    snapshot_date 
from unique_data