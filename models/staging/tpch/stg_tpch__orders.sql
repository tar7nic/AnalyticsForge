-- ============================================================
-- Model:       stg_tpch__orders.sql
-- Description: Staging model for TPC-H orders from Snowflake
--              sample data. Cleans column names to snake_case.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH source AS (

    SELECT * FROM {{ source('tpch', 'orders') }}

),

renamed AS (

    SELECT
        -- Keys
        o_orderkey AS order_key,
        o_custkey AS customer_key,

        -- Order attributes
        o_orderstatus AS order_status,
        o_orderpriority AS order_priority,
        o_clerk AS clerk,
        o_comment AS order_comment,
        TRY_TO_DECIMAL(o_totalprice, 12, 2) AS total_price,
        TRY_TO_DATE(o_orderdate::STRING) AS order_date,
        TRY_TO_NUMBER(o_shippriority) AS ship_priority,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source

)

SELECT * FROM renamed
