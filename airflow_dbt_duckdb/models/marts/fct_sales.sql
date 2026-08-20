{{ config(materialized='table') }}

with staging_product as (
    select * from {{ ref('stg_product') }}
),

staging_sales as (
    select * from {{ ref('stg_sales')}}
),
unique_product as (
    select 
        distinct 
         md5(concat_ws('|', 
        {{clean_property_text('product_key')}},
        {{clean_property_text('product')}},
        {{clean_property_text('color')}}
        )) as dwh_dim_product_id, 
        product_key as product_business_key
    from staging_product sp
)
select 
    -- PK 
    MD5(CONCAT_WS('|', 
            {{ clean_property_text('sl.sales_order_number')}},
            {{ clean_property_text('sl.product_key')}},
            {{ clean_property_text('sl.reseller_key')}},
            {{ clean_property_text('sl.sales_territory_key')}}
    )) AS dwh_fact_sales_id, 
    sl."sales_order_number", 
    sl."order_date" AS order_date, 
    sl."quantity" as quantity,
    {{clean_varchar_to_decimal('unitprice')}} as unitprice, 
    COALESCE(sl.Quantity,0) * {{clean_varchar_to_decimal('unitprice')}} AS amount, 
    sl."ingested_at", 
    sl."snapshot_date"
from staging_sales sl 
join unique_product up ON up."product_business_key" = sl."product_key" 

