INSERT INTO dwh.dim_dates (
    date_sk,
    date_actual,
    year,
    month,
    month_name,
    quarter,
    day_of_month,
    day_of_week,
    week_of_year,
    is_weekend
)
SELECT
    to_char(date_actual, 'YYYYMMDD')::INTEGER AS date_sk,
    date_actual::DATE AS date_actual,
    EXTRACT(YEAR FROM date_actual)::INTEGER AS year,
    EXTRACT(MONTH FROM date_actual)::INTEGER AS month,
    to_char(date_actual, 'FMMonth') AS month_name,
    EXTRACT(QUARTER FROM date_actual)::INTEGER AS quarter,
    EXTRACT(DAY FROM date_actual)::INTEGER AS day_of_month,
    EXTRACT(ISODOW FROM date_actual)::INTEGER AS day_of_week,
    EXTRACT(WEEK FROM date_actual)::INTEGER AS week_of_year,
    EXTRACT(ISODOW FROM date_actual)::INTEGER IN (6, 7) AS is_weekend
FROM generate_series(
    '2024-01-01'::DATE,
    '2031-12-31'::DATE,
    '1 day'::INTERVAL
) AS dates(date_actual)
ON CONFLICT (date_actual) DO NOTHING;
