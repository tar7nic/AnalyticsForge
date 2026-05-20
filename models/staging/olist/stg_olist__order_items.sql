-- ============================================================
-- Model:       stg_olist__order_items.sql
-- Description: Staging model for raw Olist order items.
--              Casts numeric fields and cleans column names.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH source AS (

    SELECT * FROM {{ source('olist', 'order_items') }}

),

renamed AS (

    SELECT
        -- Keys
        order_id,
        order_item_id,
        product_id,
        seller_id,

        -- Timestamps
        TRY_TO_TIMESTAMP(shipping_limit_date) AS shipping_limit_at,

        -- Metrics — cast to numeric for calculations
        TRY_TO_DECIMAL(price, 10, 2) AS item_price,
        TRY_TO_DECIMAL(freight_value, 10, 2) AS freight_value,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source

)

SELECT * FROM renamed
