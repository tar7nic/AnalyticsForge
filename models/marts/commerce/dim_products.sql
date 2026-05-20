-- ============================================================
-- Model:       dim_products.sql
-- Description: Product dimension table. Generates surrogate
--              keys using dbt_utils. Includes English category
--              names and physical dimensions.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH products AS (

    SELECT * FROM {{ ref('stg_olist__products') }}

),

final AS (

    SELECT
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,

        -- Natural key
        product_id,

        -- Category attributes
        product_category_english,
        product_category_portuguese,

        -- Physical dimensions
        product_weight_g,
        product_volume_cm3,
        product_length_cm,
        product_height_cm,
        product_width_cm,

        -- Metadata
        loaded_at

    FROM products

)

SELECT * FROM final
