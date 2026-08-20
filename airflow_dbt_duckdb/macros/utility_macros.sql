{% macro clean_property_text(column_name, default_value='UNKNOWN') -%}
   coalesce(nullif(upper(trim({{column_name}}::varchar)), ''), '{{ default_value }}')
{%- endmacro %}

{% macro clean_varchar_to_decimal(column_name) -%}
   replace(replace({{column_name}}, '$',''),',','')::decimal(8,3)
{%- endmacro %}
