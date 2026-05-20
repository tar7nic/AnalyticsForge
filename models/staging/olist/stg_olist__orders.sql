-- ============================================================
-- Model:       stg_olist__orders.sql
-- Description: Staging model for raw Olist orders. Cleans
--              column names, casts all types explicitly, and
--              adds loaded_at metadata timestamp.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH source AS (

    SELECT * FROM {{ source('olist', 'orders') }}

),

renamed AS (

    SELECT
        -- Primary key
        order_id,

        -- Foreign keys
        customer_id,

        -- Order attributes
        order_status,

        -- Timestamps — cast from raw string to proper timestamp
        TRY_TO_TIMESTAMP(order_purchase_timestamp) AS order_purchased_at,
        TRY_TO_TIMESTAMP(order_approved_at) AS order_approved_at,
        TRY_TO_TIMESTAMP(order_delivered_carrier_date) AS order_delivered_carrier_at,
        TRY_TO_TIMESTAMP(order_delivered_customer_date) AS order_delivered_customer_at,
        TRY_TO_TIMESTAMP(order_estimated_delivery_date) AS order_estimated_delivery_at,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source

)

SELECT * FROM renamed
