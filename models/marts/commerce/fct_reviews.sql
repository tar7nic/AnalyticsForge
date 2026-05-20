-- ============================================================
-- Model:       fct_reviews.sql
-- Description: Reviews fact table. One row per review.
--              Resolves surrogate keys to dim_customers and
--              dim_date. Links back to fct_orders via order_key.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH reviews AS (

    SELECT * FROM {{ ref('int_reviews__aggregated') }}

),

orders AS (

    SELECT * FROM {{ ref('stg_olist__orders') }}

),

dim_customers AS (

    SELECT * FROM {{ ref('dim_customers') }}

),

dim_date AS (

    SELECT * FROM {{ ref('dim_date') }}

),

final AS (

    SELECT
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['r.review_id']) }} AS review_key,

        -- Foreign keys
        {{ dbt_utils.generate_surrogate_key(['r.order_id']) }} AS order_key,
        dc.customer_key,
        dd.date_key,

        -- Natural keys
        r.review_id,
        r.order_id,

        -- Review attributes
        r.review_score,
        r.review_response_time_hours,
        r.has_comment,
        r.has_title,

        -- Timestamps
        r.review_created_at,
        r.review_answered_at,

        -- Metadata
        r.loaded_at

    FROM reviews AS r

    -- Join orders to get customer_id for dimension resolution
    LEFT JOIN orders AS o
        ON r.order_id = o.order_id

    -- Resolve customer surrogate key
    LEFT JOIN dim_customers AS dc
        ON o.customer_id = dc.customer_id

    -- Resolve date surrogate key from review creation date
    LEFT JOIN dim_date AS dd
        ON TO_NUMBER(TO_VARCHAR(r.review_created_at::DATE, 'YYYYMMDD')) = dd.date_key

)

SELECT * FROM final
