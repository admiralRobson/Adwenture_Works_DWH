with source as (
        select * from {{ source('raw_sources', 'reseller') }}
)
select 
    source."ResellerKey" as reseller_key, 
    source."Business Type"::varchar as business_type, 
    source."Reseller"::varchar as reseller, 
    source."City"::varchar as city, 
    source."State-Province"::varchar as state_province, 
    source."Country-Region"::varchar as country_region,
    source."ingested_at"::datetime as ingested_at, 
    source."snapshot_date"::date as snapshot_date
from source

