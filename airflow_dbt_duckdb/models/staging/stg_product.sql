with source as (
    -- dbt pod maską przetłumaczy to na: select * from 'data_raw/customer.parquet'
    select * from {{ source('raw_sources', 'product') }}
)
select 
    source."ProductKey" AS product_key, 
    source."Product" AS product,
    source."Standard Cost"::varchar AS standard_cost,
    source."Color"::varchar AS color,
    source."SubCategory"::varchar AS subcategory, 
    source."Category"::varchar AS category,
    source."ingested_at"::datetime AS ingested_at, 
    source."snapshot_date"::date AS snapshot_date
from source