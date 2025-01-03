-- Step 1: Calculate price changes between consecutive days for each stock symbol
WITH price_changes AS (
    SELECT
        date,  -- The date of the stock data
        symbol,  -- The symbol representing the stock
        close_price,  -- Closing price of the stock on a given day
        -- Get the previous day's close price to calculate price change
        LAG(close_price) OVER (PARTITION BY symbol ORDER BY date) AS prev_close,
        -- Calculate the price change from the previous day's closing price
        close_price - LAG(close_price) OVER (PARTITION BY symbol ORDER BY date) AS price_change
    FROM
        {{ ref('staging_table') }}  -- Pull data from the 'market_data' table in the 'stocks' source
),
-- Step 2: Separate price changes into gains and losses
gains_losses AS (
    SELECT
        date,  -- The date of the stock data
        symbol,  -- The symbol representing the stock
        -- If the price change is positive, it's a gain; otherwise, it's a loss
        CASE WHEN price_change > 0 THEN price_change ELSE 0 END AS gain,
        CASE WHEN price_change < 0 THEN ABS(price_change) ELSE 0 END AS loss
    FROM 
        price_changes
),
-- Step 3: Calculate average gains and losses over a 14-day window
avg_gains_losses AS (
    SELECT
        date,  -- The date of the stock data
        symbol,  -- The symbol representing the stock
        -- Calculate the average gain over the last 14 days
        AVG(gain) OVER (
            PARTITION BY symbol
            ORDER BY date
            ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
        ) AS avg_gain,
        -- Calculate the average loss over the last 14 days
        AVG(loss) OVER (
            PARTITION BY symbol
            ORDER BY date
            ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
        ) AS avg_loss
    FROM 
        gains_losses
)

-- Step 4: Calculate the RSI (Relative Strength Index) based on the average gain and average loss
SELECT
    date,  -- The date of the stock data
    symbol,  -- The symbol representing the stock
    100 - (100 / (1 + (avg_gain / NULLIF(avg_loss, 0)))) AS rsi  -- Formula to calculate RSI
FROM 
    avg_gains_losses -- Use the CTE holding the average gains and losses