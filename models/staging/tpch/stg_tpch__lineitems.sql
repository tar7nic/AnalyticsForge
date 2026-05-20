-- ============================================================
-- Model:       stg_tpch__lineitems.sql
-- Description: Staging model for TPC-H line items.
--              Cleans column names and casts numeric fields.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH source AS (

    SELECT * FROM {{ source('tpch', 'lineitem') }}

),

renamed AS (

    SELECT
        -- Keys
        l_orderkey AS order_key,
        l_partkey AS part_key,
        l_suppkey AS supplier_key,
        l_linenumber AS line_number,

        -- Metrics
        l_returnflag AS return_flag,
        l_linestatus AS line_status,
        TRY_TO_DECIMAL(l_quantity::VARCHAR, 12, 2) AS quantity,
        TRY_TO_DECIMAL(l_extendedprice::VARCHAR, 12, 2) AS extended_price,

        -- Flags
        TRY_TO_DECIMAL(l_discount::VARCHAR, 5, 2) AS discount,
        TRY_TO_DECIMAL(l_tax::VARCHAR, 5, 2) AS tax,

        -- Dates
        TRY_TO_DATE(l_shipdate::STRING) AS ship_date,
        TRY_TO_DATE(l_commitdate::STRING) AS commit_date,
        TRY_TO_DATE(l_receiptdate::STRING) AS receipt_date,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source

)

SELECT * FROM renamed
