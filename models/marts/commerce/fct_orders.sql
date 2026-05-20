-- ============================================================
-- Model:       fct_orders.sql
-- Description: Primary fact table for Olist orders. Joins
--              enriched orders with delivery times and reviews,
--              then resolves surrogate keys from all dimensions.
--              One row per order.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH enriched_orders AS (

    SELECT * FROM {{ ref('int_orders__enriched') }}

),

delivery_times AS (

    SELECT * FROM {{ ref('int_orders__delivery_times') }}

),

reviews AS (

    SELECT * FROM {{ ref('int_reviews__aggregated') }}

),

dim_customers AS (

    SELECT * FROM {{ ref('dim_customers') }}

),

dim_sellers AS (

    SELECT * FROM {{ ref('dim_sellers') }}

),

dim_products AS (

    SELECT * FROM {{ ref('dim_products') }}

),

dim_date AS (

    SELECT * FROM {{ ref('dim_date') }}

),

-- Resolve all surrogate keys and join all metrics
final AS (

    SELECT
        -- Surrogate key for this fact row
        {{ dbt_utils.generate_surrogate_key(['o.order_id']) }} AS order_key,

        -- Foreign keys to dimensions
        dc.customer_key,
        ds.seller_key,
        dp.product_key,
        dd.date_key,

        -- Natural key
        o.order_id,

        -- Order attributes
        o.order_status,
        o.payment_type,

        -- Item metrics
        o.order_item_count,
        o.order_item_value,
        o.order_freight_value,
        o.order_total_value,
        o.total_payment_value,
        o.payment_installments AS total_installments,

        -- Delivery metrics — from delivery times intermediate model
        dt.days_to_deliver,
        dt.days_vs_estimate,
        dt.days_to_carrier,
        dt.days_carrier_to_customer,
        COALESCE(dt.is_late_delivery, FALSE) AS is_late_delivery,
        COALESCE(dt.is_severely_late, FALSE) AS is_severely_late,

        -- Review metrics — from reviews intermediate model
        r.review_score,
        r.review_response_time_hours,
        COALESCE(r.has_comment, FALSE) AS has_review_comment,

        -- Timestamps
        o.order_purchased_at,
        o.order_approved_at,
        o.order_delivered_customer_at,
        o.order_estimated_delivery_at,

        -- Metadata
        o.loaded_at

    FROM enriched_orders AS o

    -- Resolve customer surrogate key
    LEFT JOIN dim_customers AS dc
        ON o.customer_id = dc.customer_id

    -- Resolve seller surrogate key
    LEFT JOIN dim_sellers AS ds
        ON o.seller_id = ds.seller_id

    -- Resolve product surrogate key
    LEFT JOIN dim_products AS dp
        ON o.product_id = dp.product_id

    -- Resolve date surrogate key from purchase date
    LEFT JOIN dim_date AS dd
        ON TO_NUMBER(TO_VARCHAR(o.order_purchased_at::DATE, 'YYYYMMDD')) = dd.date_key

    -- Left join delivery — only delivered orders have these metrics
    LEFT JOIN delivery_times AS dt
        ON o.order_id = dt.order_id

    -- Left join reviews — not all orders have reviews
    LEFT JOIN reviews AS r
        ON o.order_id = r.order_id

)

SELECT * FROM final
