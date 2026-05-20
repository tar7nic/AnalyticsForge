-- ============================================================
-- Model:       stg_olist__order_payments.sql
-- Description: Staging model for raw Olist order payments.
--              One row per payment installment per order.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH source AS (

    SELECT * FROM {{ source('olist', 'order_payments') }}

),

renamed AS (

    SELECT
        -- Keys
        order_id,

        -- Payment attributes
        payment_sequential,
        payment_type,
        TRY_TO_NUMBER(payment_installments) AS payment_installments,
        TRY_TO_DECIMAL(payment_value, 10, 2) AS payment_value,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source

)

SELECT * FROM renamed
