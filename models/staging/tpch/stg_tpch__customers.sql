-- ============================================================
-- Model:       stg_tpch__customers.sql
-- Description: Staging model for TPC-H customers.
--              Cleans column names to snake_case.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH source AS (

    SELECT * FROM {{ source('tpch', 'customer') }}

),

renamed AS (

    SELECT
        -- Keys
        c_custkey AS customer_key,
        c_nationkey AS nation_key,

        -- Customer attributes
        c_name AS customer_name,
        c_address AS customer_address,
        c_phone AS customer_phone,
        c_mktsegment AS market_segment,
        c_comment AS customer_comment,
        TRY_TO_DECIMAL(c_acctbal, 12, 2) AS account_balance,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source

)

SELECT * FROM renamed
