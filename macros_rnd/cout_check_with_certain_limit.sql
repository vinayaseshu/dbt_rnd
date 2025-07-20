{% test cout_check_with_certain_limit(model, column_name, limit_value) %}
SELECT *
FROM {{ model }}
WHERE {{ column_name }} < {{ limit_value }}
{% endtest %}
