-- ============================================================
-- Macro:       cents_to_dollars
-- Description: Converts a value in cents (integer) to dollars
--              (decimal with 2 places). Safe against nulls.
-- Usage:       {{ cents_to_dollars('amount_cents') }}
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

{% macro cents_to_dollars(column_name, scale=2) %}
    ROUND(
        COALESCE({{ column_name }}, 0) / 100.0,
        {{ scale }}
    )
{% endmacro %}
