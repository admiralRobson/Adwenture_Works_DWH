with source as (
    -- dbt pod maską przetłumaczy to na: select * from 'data_raw/customer.parquet'
    select * from {{ source('raw_sources', 'sales') }}
)

select
    source."SalesOrderNumber"::varchar as sales_order_number, 
    source."OrderDate" as order_date,
    source."ProductKey"::int as product_key, 
    source."ResellerKey"::int as reseller_key, 
    source."EmployeeKey"::int as employee_key, 
    source."SalesTerritoryKey" as sales_territory_key, 
    source."Quantity" as quantity, 
    source."Unit Price" as UnitPrice, 
    source."ingested_at",
    source."snapshot_date"
from source


