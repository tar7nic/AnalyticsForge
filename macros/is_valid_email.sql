-- ============================================================
-- Macro:       is_valid_email
-- Description: Returns TRUE if the column value looks like a
--              valid email address using regex pattern match.
--              Used in data quality checks.
-- Usage:       {{ is_valid_email('email_column') }}
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

{% macro is_valid_email(column_name) %}
    REGEXP_LIKE(
        {{ column_name }},
        '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
    )
{% endmacro %}
