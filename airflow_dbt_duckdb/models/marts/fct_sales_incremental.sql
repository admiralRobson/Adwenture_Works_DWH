-- konfiguracja danych dotycząca incremental 
{{ config(
    materialized='incremental',
    unique_key='sales_order_number',
    incremental_strategy='delete+insert',
    on_schema_change='append_new_columns'
) }}

with staging_product as (
    select * from {{ ref('stg_product') }}
),

staging_sales as (
    select * from {{ ref('stg_sales')}}
),

staging_reseller as (
    select * from {{ref('stg_reseller')}}
),

staging_target as (
    select * from {{ref('stg_target')}}
),

staging_sales_person as (
    select * from {{ref('stg_sales_person')}}
),
unique_product as (
    select 
        distinct 
         md5(concat_ws('|', 
        {{clean_property_text('product_key')}},
        {{clean_property_text('product')}},
        {{clean_property_text('color')}}
        )) as dwh_dim_product_id, 
        sp."product_key" as product_business_key
    from staging_product sp
),

unique_reseller as (
    select 
    distinct
             MD5(CONCAT_WS('|', 
        {{clean_property_text('reseller_key')}},
        {{clean_property_text('reseller')}},
        {{clean_property_text('city')}}
        )) as "dwh_dim_reseller_id",
        staging_reseller."reseller_key", 
        staging_reseller."business_type", 
        staging_reseller."reseller", 
        staging_reseller."city", 
        staging_reseller."state_province", 
        staging_reseller."country_region",
        staging_reseller."ingested_at", 
        staging_reseller."snapshot_date"
    from staging_reseller
),

unique_target as (
    select 
        distinct 
        MD5(CONCAT_WS('|', 
        {{clean_property_text('employee_id')}},
        {{clean_property_text('target_month')}})) as dwh_dim_targets_id, 
        employee_id,
        target, 
        target_month, 
        ingested_at, 
        snapshot_date
    from staging_target
),

unique_sales_person as (
    select 
        distinct 
             MD5(concat_ws('|',
            {{clean_property_text('employee_key')}},
            {{clean_property_text('employee_id')}},
            {{clean_property_text('sales_person')}}
                )) as dwh_dim_sales_person_id,
            ssp."employee_key", 
            ssp."employee_id",
            ssp."sales_person", 
            ssp."title", 
            ssp."upn",
            ssp."ingested_at", 
            ssp."snapshot_date" 
    from staging_sales_person ssp
)

select 
    -- PK 
    MD5(CONCAT_WS('|', 
            {{ clean_property_text('sl.sales_order_number')}},
            {{ clean_property_text('sl.product_key')}},
            {{ clean_property_text('sl.reseller_key')}},
            {{ clean_property_text('sl.sales_territory_key')}}
    )) AS dwh_fact_sales_id, 
    up."dwh_dim_product_id" as dwh_dim_product_id,
    ur."dwh_dim_reseller_id" as  dwh_dim_reseller_id,
    usp."dwh_dim_sales_person_id" as dwh_dim_sales_person_id,
    sl."sales_order_number", 
    sl."order_date" AS order_date, 
    sl."quantity" as quantity,
    {{clean_varchar_to_decimal('unitprice')}} as unitprice, 
    COALESCE(sl.Quantity,0) * {{clean_varchar_to_decimal('unitprice')}} AS amount, 
    sl."ingested_at", 
    sl."snapshot_date"
from staging_sales sl 
join unique_product up ON up."product_business_key" = sl."product_key" 
join unique_reseller ur ON ur."reseller_key" = sl."reseller_key"
join unique_sales_person usp ON usp."employee_key" = sl."employee_key"


{% if is_incremental() -%}
    -- Ten fragment wykonuje się TYLKO podczas kolejnych uruchomień dbt run.
    -- Dociągamy wyłącznie rekordy z datą nowszą niż największa data w istniejącej już tabeli docelowej.
where sl."order_date" >= (
      select max(target."order_date") from {{this}} as target
       
  )
{%- endif %}


