{% snapshot scd_product -%}

{{
    config(
      target_schema='marts',
      unique_key='product_key',
      strategy='check',
      check_cols=['color', 'subcategory','category','standard_cost'],
      invalidate_hard_deletes=True
    )
}}

select 
    
    product, 
    product_key,
    {{clean_varchar_to_decimal('standard_cost')}} as standard_cost,
    color, 
    subcategory, 
    category,
    ingested_at, 
    snapshot_date 
from {{ ref('stg_product') }}

{%- endsnapshot %}