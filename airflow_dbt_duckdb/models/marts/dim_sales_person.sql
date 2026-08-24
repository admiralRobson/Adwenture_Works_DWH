{{ config(materialized='table') }}

with staging_data as (
    select * from {{ ref('stg_sales_person') }}
),
unique_data as (
    select 
        distinct
            employee_key, -- klucz główny dla tabeli 
            employee_id,
            sales_person, 
            title, 
            upn,
            ingested_at, 
            snapshot_date 
    from staging_data

)
select 
    MD5(concat_ws('|',
        {{clean_property_text('employee_key')}},
        {{clean_property_text('employee_id')}},
        {{clean_property_text('sales_person')}}
    )) as dwh_dim_sales_person_id, 
    employee_key, 
    employee_id,
    sales_person, 
    title, 
    upn,
    ingested_at, 
    snapshot_date 
from unique_data
