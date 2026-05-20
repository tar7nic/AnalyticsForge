-- ============================================================
-- Model:       stg_olist__products.sql
-- Description: Staging model for raw Olist products.
--              Casts numeric dimensions and joins category
--              translation inline for convenience.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH source AS (

    SELECT * FROM {{ source('olist', 'products') }}

),

translation AS (

    SELECT * FROM {{ source('olist', 'product_category_name_translation') }}

),

renamed AS (

    SELECT
        -- Keys
        s.product_id,

        -- Category — both languages
        s.product_category_name AS product_category_portuguese,
        COALESCE(t.product_category_name_english, 'unknown') AS product_category_english,

        -- Physical dimensions — cast to numeric
        TRY_TO_NUMBER(s.product_name_lenght) AS product_name_length,
        TRY_TO_NUMBER(s.product_description_lenght) AS product_description_length,
        TRY_TO_NUMBER(s.product_photos_qty) AS product_photos_qty,
        TRY_TO_DECIMAL(s.product_weight_g, 10, 2) AS product_weight_g,
        TRY_TO_DECIMAL(s.product_length_cm, 10, 2) AS product_length_cm,
        TRY_TO_DECIMAL(s.product_height_cm, 10, 2) AS product_height_cm,
        TRY_TO_DECIMAL(s.product_width_cm, 10, 2) AS product_width_cm,

        -- Derived — volume in cm3
        TRY_TO_DECIMAL(s.product_length_cm, 10, 2)
        * TRY_TO_DECIMAL(s.product_height_cm, 10, 2)
        * TRY_TO_DECIMAL(s.product_width_cm, 10, 2) AS product_volume_cm3,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source AS s
    LEFT JOIN translation AS t
        ON s.product_category_name = t.product_category_name

)

SELECT * FROM renamed
