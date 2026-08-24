with source as (
    select * from {{source('raw_sources','sales_person')}}
)
select 
    source."EmployeeKey"::int as employee_key, -- klucz główny dla tabeli 
    source."EmployeeID"::varchar as employee_id,
    source."Salesperson"::varchar as sales_person, 
    source."Title"::varchar as title, 
    source."UPN"::varchar as "upn",
    source."ingested_at"::datetime as ingested_at, 
    source."snapshot_date"::date as snapshot_date 
from source 