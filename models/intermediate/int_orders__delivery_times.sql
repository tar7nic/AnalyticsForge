-- ============================================================
-- Model:       int_orders__delivery_times.sql
-- Description: Calculates delivery time metrics for each order.
--              Determines if delivery was late vs estimated date,
--              days to deliver, and SLA breach flag.
--              Only includes orders with a delivered status.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH enriched_orders AS (

    SELECT * FROM {{ ref('int_orders__enriched') }}

),

delivery_calculations AS (

    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchased_at,
        order_approved_at,
        order_delivered_carrier_at,
        order_delivered_customer_at,
        order_estimated_delivery_at,

        -- Days from purchase to actual customer delivery
        loaded_at,

        -- Days from purchase to estimated delivery
        DATEDIFF(
            'day',
            order_purchased_at,
            order_delivered_customer_at
        ) AS days_to_deliver,

        -- How many days early or late vs estimate
        -- Negative = early, Positive = late
        DATEDIFF(
            'day',
            order_purchased_at,
            order_estimated_delivery_at
        ) AS days_estimated,

        -- Days from purchase to carrier handoff
        DATEDIFF(
            'day',
            order_estimated_delivery_at,
            order_delivered_customer_at
        ) AS days_vs_estimate,

        -- Days from carrier handoff to customer delivery
        DATEDIFF(
            'day',
            order_purchased_at,
            order_delivered_carrier_at
        ) AS days_to_carrier,

        -- Boolean flags
        DATEDIFF(
            'day',
            order_delivered_carrier_at,
            order_delivered_customer_at
        ) AS days_carrier_to_customer,

        COALESCE(order_delivered_customer_at > order_estimated_delivery_at, FALSE) AS is_late_delivery,

        -- Metadata
        COALESCE(DATEDIFF(
            'day',
            order_estimated_delivery_at,
            order_delivered_customer_at
        ) > 7, FALSE) AS is_severely_late

    FROM enriched_orders
    -- Only calculate delivery times for orders that were actually delivered
    WHERE
        order_status = 'delivered'
        AND order_delivered_customer_at IS NOT NULL
        AND order_purchased_at IS NOT NULL

)

SELECT * FROM delivery_calculations
