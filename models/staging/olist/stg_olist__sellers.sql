-- ============================================================
-- Model:       stg_olist__sellers.sql
-- Description: Staging model for raw Olist sellers.
--              Cleans location fields and standardizes naming.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH source AS (

    SELECT * FROM {{ source('olist', 'sellers') }}

),

renamed AS (

    SELECT
        -- Keys
        seller_id,

        -- Location attributes
        seller_zip_code_prefix AS seller_zip_code,
        LOWER(TRIM(seller_city)) AS seller_city,
        UPPER(TRIM(seller_state)) AS seller_state,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source

)

SELECT * FROM renamed
