-- ============================================================
-- Model:       stg_olist__geolocation.sql
-- Description: Staging model for raw Olist geolocation data.
--              Maps Brazilian zip codes to coordinates and city.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH source AS (

    SELECT * FROM {{ source('olist', 'geolocation') }}

),

renamed AS (

    SELECT
        -- Keys
        geolocation_zip_code_prefix AS zip_code,

        -- Coordinates
        TRY_TO_DECIMAL(geolocation_lat, 18, 6) AS latitude,
        TRY_TO_DECIMAL(geolocation_lng, 18, 6) AS longitude,

        -- Location attributes
        LOWER(TRIM(geolocation_city)) AS city,
        UPPER(TRIM(geolocation_state)) AS state,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source

)

SELECT * FROM renamed
