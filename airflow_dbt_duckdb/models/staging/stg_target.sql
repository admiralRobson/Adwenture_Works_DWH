with source as (
    select * from {{source('raw_sources','targets')}}
)
select 
    "EmployeeID" as employee_id, 
    "Target"::varchar as target, 
    "TargetMonth"::varchar as target_month, 
    "ingested_at"::datetime as ingested_at, 
    "snapshot_date"::date as snapshot_date 
from source