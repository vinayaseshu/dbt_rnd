{% test test_references_multi_column_with_threshold(
    model,
    model_columns,
    reference_model,
    reference_columns,
    threshold=0.0
) %}

WITH joined AS (
    SELECT
        m.*,
        {% for r_col in reference_columns %}
            r.{{ r_col }} AS r_{{ r_col }}
            {%- if not loop.last %}, {% endif %}
        {% endfor %}
    FROM {{ model }} AS m
    LEFT JOIN {{ reference_model }} AS r
        ON
        {% for m_col, r_col in zip(model_columns, reference_columns) %}
            {% if not loop.first %} AND {% endif %}
            (
              m.{{ m_col | trim | replace('`', '') | lower }} IS NOT DISTINCT FROM
              r.{{ r_col | trim | replace('`', '') | lower }}
            )
        {% endfor %}
),

invalid_rows AS (
    SELECT *
    FROM joined
    WHERE
        {% for r_col in reference_columns %}
            r_{{ r_col }} IS NULL
            {%- if not loop.last %} AND {% endif %}
        {% endfor %}
)

SELECT *
FROM invalid_rows

{% if threshold > 0 %}
-- Fail only if mismatches exceed the threshold
HAVING COUNT(*) > (
    SELECT COUNT(*) * {{ threshold }}
    FROM {{ model }}
)
{% endif %}

{% endtest %}
