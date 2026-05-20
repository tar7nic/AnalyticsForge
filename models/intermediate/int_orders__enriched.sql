-- ============================================================
-- Model:       int_orders__enriched.sql
-- Description: Joins orders, order items, and payments into
--              one wide model. Aggregates item-level metrics
--              to order level. This is the primary input for
--              fct_orders in the mart layer.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH orders AS (

    SELECT * FROM {{ ref('stg_olist__orders') }}

),

order_items AS (

    SELECT * FROM {{ ref('stg_olist__order_items') }}

),

payments AS (

    SELECT * FROM {{ ref('stg_olist__order_payments') }}

),

-- Aggregate items to order level
items_aggregated AS (

    SELECT
        order_id,
        COUNT(*) AS order_item_count,
        SUM(item_price) AS order_item_value,
        SUM(freight_value) AS order_freight_value,
        SUM(item_price + freight_value) AS order_total_value,
        MIN(seller_id) AS primary_seller_id,
        MIN(product_id) AS primary_product_id,
        MIN(shipping_limit_at) AS shipping_limit_at

    FROM order_items
    GROUP BY order_id

),

-- Aggregate payments to order level
-- Take the most common payment type per order
payments_aggregated AS (

    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value,
        MAX(payment_installments) AS max_payment_installments,
        -- Most common payment type using mode approximation
        MODE(payment_type) AS primary_payment_type

    FROM payments
    GROUP BY order_id

),

-- Join everything together
joined AS (

    SELECT
        -- Order identifiers
        o.order_id,
        o.customer_id,
        i.primary_seller_id AS seller_id,
        i.primary_product_id AS product_id,

        -- Order status and timestamps
        o.order_status,
        o.order_purchased_at,
        o.order_approved_at,
        o.order_delivered_carrier_at,
        o.order_delivered_customer_at,
        o.order_estimated_delivery_at,
        i.shipping_limit_at,

        -- Item metrics
        i.order_item_count,
        i.order_item_value,
        i.order_freight_value,
        i.order_total_value,

        -- Payment metrics
        p.primary_payment_type AS payment_type,
        p.total_payment_value,
        p.max_payment_installments AS payment_installments,

        -- Metadata
        o.loaded_at

    FROM orders AS o
    LEFT JOIN items_aggregated AS i
        ON o.order_id = i.order_id
    LEFT JOIN payments_aggregated AS p
        ON o.order_id = p.order_id

)

SELECT * FROM joined
