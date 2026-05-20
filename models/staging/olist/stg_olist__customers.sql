-- ============================================================
-- Model:       stg_olist__customers.sql
-- Description: Staging model for raw Olist customers.
--              Cleans location fields and standardizes naming.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH source AS (

    SELECT * FROM {{ source('olist', 'customers') }}

),

renamed AS (

    SELECT
        -- Keys
        customer_id,
        customer_unique_id,

        -- Location attributes
        customer_zip_code_prefix AS customer_zip_code,
        LOWER(TRIM(customer_city)) AS customer_city,
        UPPER(TRIM(customer_state)) AS customer_state,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source

)

SELECT * FROM renamed
