
    
    



with __dbt__cte__staging_table as (
-- staging table for market_data
WITH source_data AS (
    SELECT
        symbol,
        date,
        open,
        high,
        low,
        close,
        volume
    FROM lab2.raw_data.market_data
)

SELECT
    symbol,
    date,
    CAST(open AS FLOAT) AS open_price,   -- Standardize column names and data types
    CAST(high AS FLOAT) AS high_price,
    CAST(low AS FLOAT) AS low_price,
    CAST(close AS FLOAT) AS close_price,
    volume
FROM source_data
) select date
from __dbt__cte__staging_table
where date is null


