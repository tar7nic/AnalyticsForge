-- ============================================================
-- Model:       stg_olist__order_reviews.sql
-- Description: Staging model for raw Olist order reviews.
--              Casts review score to integer and timestamps.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH source AS (

    SELECT * FROM {{ source('olist', 'order_reviews') }}

),

renamed AS (

    SELECT
        -- Keys
        review_id,
        order_id,

        -- Review attributes
        review_comment_title,
        review_comment_message,
        TRY_TO_NUMBER(review_score) AS review_score,

        -- Timestamps
        TRY_TO_TIMESTAMP(review_creation_date) AS review_created_at,
        TRY_TO_TIMESTAMP(review_answer_timestamp) AS review_answered_at,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source

)

SELECT * FROM renamed
