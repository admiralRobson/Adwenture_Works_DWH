{% test not_negative(model, column_name, min_value = 0) -%}

-- Test szuka wierszy, które ŁAMIĄ naszą regułę biznesową.
-- Jeśli znajdzie chociaż jeden wiersz poniżej min_value lub powyżej max_value, test zgłosi FAIL.
with validation as (
    select
        {{ column_name }} as validate_column
    from {{ model }}
)

select
    validate_column
from validation
where validate_column < {{ min_value }}
   
{%- endtest %}