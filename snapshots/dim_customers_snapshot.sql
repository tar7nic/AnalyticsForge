-- ============================================================
-- Snapshot:    dim_customers_snapshot.sql
-- Description: SCD Type 2 snapshot on the customers staging
--              model. Tracks changes to customer city and state
--              over time. dbt adds dbt_scd_id, dbt_valid_from,
--              dbt_valid_to, and dbt_updated_at automatically.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

{% snapshot dim_customers_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='check',
        check_cols=['customer_city', 'customer_state', 'customer_zip_code'],
        invalidate_hard_deletes=True
    )
}}

    SELECT
        customer_id AS customer_id,
        customer_unique_id AS customer_unique_id,
        customer_zip_code AS customer_zip_code,
        customer_city AS customer_city,
        customer_state AS customer_state,
        loaded_at AS loaded_at

    FROM {{ ref('stg_olist__customers') }}

{% endsnapshot %}
