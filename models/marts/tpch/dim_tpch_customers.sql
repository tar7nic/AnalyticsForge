-- ============================================================
-- Model:       dim_tpch_customers.sql
-- Description: Customer dimension for TPC-H dataset.
--              Demonstrates surrogate key generation on
--              Snowflake-native sample data.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH customers AS (

    SELECT * FROM {{ ref('stg_tpch__customers') }}

),

final AS (

    SELECT
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['customer_key']) }} AS customer_surrogate_key,

        -- Natural key
        customer_key,
        nation_key,

        -- Customer attributes
        customer_name,
        customer_address,
        customer_phone,
        account_balance,
        market_segment,

        -- Metadata
        loaded_at

    FROM customers

)

SELECT * FROM final
