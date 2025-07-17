{% test test_references_multi_column(model, model_columns, reference_model, reference_columns) %}

SELECT *
FROM {{ model }} AS m
LEFT JOIN {{ reference_model }} AS r
    ON
    {% for m_col, r_col in zip(model_columns, reference_columns) %}
        {% if not loop.first %} AND {% endif %}
        m.{{ m_col }} = r.{{ r_col }}
    {% endfor %}
WHERE
    {% for r_col in reference_columns %}
        {% if not loop.first %} AND {% endif %}
        r.{{ r_col }} IS NULL
    {% endfor %}

{% endtest %}
