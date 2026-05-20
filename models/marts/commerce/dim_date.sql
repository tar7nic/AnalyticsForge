-- ============================================================
-- Model:       dim_date.sql
-- Description: Date dimension table covering 2016-01-01 to
--              2018-12-31 (full Olist dataset range). Generated
--              using dbt_utils.date_spine macro. Includes all
--              calendar attributes and Brazilian public holiday
--              flag joined from the br_public_holidays seed.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH date_spine AS (

    {{
        dbt_utils.date_spine(
            datepart = "day",
            start_date = "cast('2016-01-01' as date)",
            end_date = "cast('2019-01-01' as date)"
        )
    }}

),

holidays AS (

    SELECT * FROM {{ ref('br_public_holidays') }}

),

dates_with_attributes AS (

    SELECT
        -- Surrogate key — integer YYYYMMDD format for fast joining
        date_day AS full_date,

        -- Full date
        h.holiday_name AS holiday_name_br,

        -- Day attributes
        TO_NUMBER(TO_VARCHAR(date_day, 'YYYYMMDD')) AS date_key,
        DAY(date_day) AS day_of_month,
        DAYOFWEEK(date_day) AS day_of_week_number,

        -- Week attributes
        DAYNAME(date_day) AS day_name,

        -- Month attributes
        WEEKOFYEAR(date_day) AS week_of_year,
        MONTH(date_day) AS month_number,

        -- Quarter and year
        MONTHNAME(date_day) AS month_name,
        QUARTER(date_day) AS quarter_number,

        -- Boolean flags
        YEAR(date_day) AS year_number,

        -- Brazilian public holiday flag from seed
        COALESCE(DAYOFWEEK(date_day) IN (0, 6), FALSE) AS is_weekend,

        COALESCE(h.holiday_date IS NOT NULL, FALSE) AS is_holiday_br

    FROM date_spine AS ds
    LEFT JOIN holidays AS h
        ON ds.date_day = h.holiday_date

)

SELECT * FROM dates_with_attributes
