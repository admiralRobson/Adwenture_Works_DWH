{{ config(materialized='table') }}

with staging as (
    select * from {{ref('stg_target')}}
),
unique_targets as (
    select 
        distinct 
            employee_id, 
            target, 
            target_month, 
            ingested_at, 
            snapshot_date 
    from staging

)
select 
    MD5(CONCAT_WS('|', 
        {{clean_property_text('employee_id')}},
        {{clean_property_text('target_month')}})) as dwh_dim_targets_id, 
    employee_id,
    target, 
    target_month, 
    ingested_at, 
    snapshot_date
from staging