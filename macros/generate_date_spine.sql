-- ============================================================
-- Macro:       generate_date_spine
-- Description: Wrapper around dbt_utils.date_spine for
--              consistent date range generation across models.
--              Defaults to the full Olist dataset date range.
-- Usage:       {{ generate_date_spine() }}
--              {{ generate_date_spine('2020-01-01', '2023-01-01') }}
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

{% macro generate_date_spine(start_date='2016-01-01', end_date='2019-01-01') %}
    {{
        dbt_utils.date_spine(
            datepart = "day",
            start_date = "cast('" ~ start_date ~ "' as date)",
            end_date = "cast('" ~ end_date ~ "' as date)"
        )
    }}
{% endmacro %}
