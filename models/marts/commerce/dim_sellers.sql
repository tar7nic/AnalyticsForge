-- ============================================================
-- Model:       dim_sellers.sql
-- Description: Seller dimension table. Generates surrogate
--              keys using dbt_utils. One row per seller.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH sellers AS (

    SELECT * FROM {{ ref('stg_olist__sellers') }}

),

final AS (

    SELECT
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['seller_id']) }} AS seller_key,

        -- Natural key
        seller_id,

        -- Location attributes
        seller_zip_code,
        seller_city,
        seller_state,

        -- Metadata
        loaded_at

    FROM sellers

)

SELECT * FROM final
