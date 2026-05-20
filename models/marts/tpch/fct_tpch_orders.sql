-- ============================================================
-- Model:       fct_tpch_orders.sql
-- Description: Fact table for TPC-H orders. Joins orders with
--              aggregated line item metrics. Demonstrates
--              Snowflake-native querying capability.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH orders AS (

    SELECT * FROM {{ ref('stg_tpch__orders') }}

),

lineitems AS (

    SELECT * FROM {{ ref('stg_tpch__lineitems') }}

),

-- Aggregate line items to order level
lineitems_aggregated AS (

    SELECT
        order_key,
        COUNT(*) AS line_item_count,
        SUM(extended_price) AS gross_revenue,
        SUM(extended_price * (1 - discount)) AS net_revenue,
        SUM(extended_price * discount) AS total_discount,
        SUM(extended_price * tax) AS total_tax,
        AVG(discount) AS avg_discount_rate

    FROM lineitems
    GROUP BY order_key

),

final AS (

    SELECT
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['o.order_key']) }} AS order_surrogate_key,

        -- Foreign keys
        {{ dbt_utils.generate_surrogate_key(['o.customer_key']) }} AS customer_surrogate_key,

        -- Natural keys
        o.order_key,
        o.customer_key,

        -- Order attributes
        o.order_status,
        o.order_priority,
        o.order_date,
        o.clerk,

        -- Line item metrics
        COALESCE(la.line_item_count, 0) AS line_item_count,
        COALESCE(la.gross_revenue, 0) AS gross_revenue,
        COALESCE(la.net_revenue, 0) AS net_revenue,
        COALESCE(la.total_discount, 0) AS total_discount,
        COALESCE(la.total_tax, 0) AS total_tax,
        COALESCE(la.avg_discount_rate, 0) AS avg_discount_rate,

        -- Metadata
        o.loaded_at

    FROM orders AS o
    LEFT JOIN lineitems_aggregated AS la
        ON o.order_key = la.order_key

)

SELECT * FROM final
