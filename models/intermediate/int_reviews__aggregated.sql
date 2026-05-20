-- ============================================================
-- Model:       int_reviews__aggregated.sql
-- Description: Aggregates review data to the order level.
--              Calculates review response time, flags orders
--              with comment text, and handles duplicate reviews
--              by keeping the most recent one per order.
-- Author:      Tarun Nichwani
-- Last Modified: 2026-05-20
-- ============================================================

WITH reviews AS (

    SELECT * FROM {{ ref('stg_olist__order_reviews') }}

),

-- Some orders have multiple reviews — keep the latest one per order
deduped_reviews AS (

    SELECT *
    FROM reviews
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY order_id
        ORDER BY review_created_at DESC
    ) = 1

),

final AS (

    SELECT
        -- Keys
        review_id,
        order_id,

        -- Review attributes
        review_score,
        review_comment_title,
        review_comment_message,

        -- Timestamps
        review_created_at,
        review_answered_at,

        -- Derived: how many hours did it take to get a response?
        loaded_at,

        -- Boolean: did the customer leave a written comment?
        DATEDIFF(
            'hour',
            review_created_at,
            review_answered_at
        ) AS review_response_time_hours,

        -- Boolean: was a review title provided?
        COALESCE(
            review_comment_message IS NOT NULL
            AND TRIM(review_comment_message) != '', FALSE
        ) AS has_comment,

        -- Metadata
        COALESCE(
            review_comment_title IS NOT NULL
            AND TRIM(review_comment_title) != '', FALSE
        ) AS has_title

    FROM deduped_reviews

)

SELECT * FROM final
