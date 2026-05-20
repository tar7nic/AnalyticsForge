-- ============================================================
-- Macro:       safe_divide
-- Description: Divides numerator by denominator safely.
--              Returns NULL instead of error when denominator
--              is zero or null. Used for rate calculations.
-- Usage:       {{ safe_divide('total_revenue', 'order_count') }}
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

{% macro safe_divide(numerator, denominator) %}
    CASE
        WHEN {{ denominator }} IS NULL OR {{ denominator }} = 0
            THEN NULL
        ELSE {{ numerator }} / {{ denominator }}
    END
{% endmacro %}
