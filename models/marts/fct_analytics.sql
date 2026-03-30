{{ config(
    materialized='external',
    location='s3://curated/fct_analytics.parquet'
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_raw_data') }}
),
aggregated_data AS (
    SELECT 
        status,
        DATE_TRUNC('month', transaction_date) AS transaction_month,
        COUNT(DISTINCT user_id) AS unique_users,
        COUNT(*) AS total_transactions,
        SUM(transaction_amount) AS total_amount,
        AVG(transaction_amount) AS avg_amount
    FROM source_data
    GROUP BY 1, 2
)

SELECT * FROM aggregated_data
