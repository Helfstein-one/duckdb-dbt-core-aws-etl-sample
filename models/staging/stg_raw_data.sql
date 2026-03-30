{{ config(materialized='view') }}

WITH raw_data AS (
    -- Lazy read from MinIO S3 bucket landing
    SELECT *
    FROM read_parquet('s3://landing/*.parquet')
)

SELECT 
    user_id::VARCHAR AS user_id,
    user_name::VARCHAR AS user_name,
    transaction_amount::DOUBLE AS transaction_amount,
    transaction_date::TIMESTAMP AS transaction_date,
    status::VARCHAR AS status
FROM raw_data
