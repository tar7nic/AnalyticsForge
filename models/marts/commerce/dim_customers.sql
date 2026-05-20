-- ============================================================
-- Model:       dim_customers.sql
-- Description: Customer dimension table. Generates surrogate
--              keys using dbt_utils. One row per unique
--              customer_id from the Olist dataset.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH customers AS (

    SELECT * FROM {{ ref('stg_olist__customers') }}

),

final AS (

    SELECT
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS customer_key,

        -- Natural key
        customer_id,
        customer_unique_id,

        -- Location attributes
        customer_zip_code,
        customer_city,
        customer_state,

        -- Metadata
        loaded_at

    FROM customers

)

SELECT * FROM final
