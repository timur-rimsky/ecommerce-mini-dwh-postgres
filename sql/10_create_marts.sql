-- Create analytical marts for e-commerce DWH.
-- Marts are recreated on each run to reflect the latest loaded data.

DROP TABLE IF EXISTS marts.mart_ab_test_result;
DROP TABLE IF EXISTS marts.mart_funnel_by_variant;
DROP TABLE IF EXISTS marts.mart_orders_by_city;
DROP TABLE IF EXISTS marts.mart_revenue_by_category;
DROP TABLE IF EXISTS marts.mart_revenue_by_month;


-- Mart 1: revenue and orders by month.
-- Grain: one row per year and month.

CREATE TABLE marts.mart_revenue_by_month AS
SELECT
    d.year AS year,
    d.month AS month,
    COUNT(DISTINCT o.order_sk) AS orders_count,
    SUM(o.order_total_amount) AS total_revenue,
    AVG(o.order_total_amount) AS avg_order_value
FROM dwh.fact_orders o
JOIN dwh.dim_dates d ON o.order_date_sk = d.date_sk
WHERE o.order_status IN ('paid', 'delivered')
GROUP BY
    d.year,
    d.month
ORDER BY
    d.year,
    d.month;


-- Mart 2: revenue by product category.
-- Revenue is calculated from fact_order_items because category is product-level.

CREATE TABLE marts.mart_revenue_by_category AS
SELECT
    p.category AS category,
    SUM(oi.line_total) AS total_revenue,
    COUNT(DISTINCT o.order_sk) AS orders_count,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.line_total) / NULLIF(SUM(oi.quantity), 0) AS avg_item_price
FROM dwh.fact_order_items oi
JOIN dwh.fact_orders o ON oi.order_sk = o.order_sk
JOIN dwh.dim_products p ON oi.product_sk = p.product_sk
WHERE o.order_status IN ('paid', 'delivered')
GROUP BY
    p.category
ORDER BY
    total_revenue DESC;


-- Mart 3: orders, revenue and shipping cost by city.
-- Grain: one row per shipping city.

CREATE TABLE marts.mart_orders_by_city AS
SELECT
    shipping_city AS city,
    COUNT(DISTINCT order_sk) AS orders_count,
    SUM(order_total_amount) AS total_revenue,
    AVG(order_total_amount) AS avg_order_amount,
    SUM(shipping_cost) AS total_shipping_cost,
    AVG(shipping_cost) AS avg_shipping_cost
FROM dwh.fact_orders
WHERE order_status IN ('paid', 'delivered')
GROUP BY
    shipping_city
ORDER BY
    total_revenue DESC;


-- Mart 4: user funnel by A/B test variant.
-- Events are counted only after the user was assigned to the experiment.

CREATE TABLE marts.mart_funnel_by_variant AS
WITH assigned_users AS (
    SELECT DISTINCT
        experiment_name,
        experiment_variant,
        user_sk,
        assigned_at
    FROM dwh.fact_ab_assignments
),

funnel AS (
    SELECT
        a.experiment_name,
        a.experiment_variant,
        COUNT(
            DISTINCT CASE WHEN e.event_type = 'view_product' THEN a.user_sk END
        ) AS view_product_users,
        COUNT(
            DISTINCT CASE WHEN e.event_type = 'add_to_cart' THEN a.user_sk END
        ) AS add_to_cart_users,
        COUNT(
            DISTINCT CASE WHEN e.event_type = 'checkout' THEN a.user_sk END
        ) AS checkout_users,
        COUNT(
            DISTINCT CASE WHEN e.event_type = 'purchase' THEN a.user_sk END
        ) AS purchase_users
    FROM assigned_users a
    LEFT JOIN dwh.fact_user_events e
        ON a.user_sk = e.user_sk
        AND e.event_time >= a.assigned_at
    GROUP BY
        a.experiment_name,
        a.experiment_variant
)

SELECT
    experiment_name,
    experiment_variant,
    view_product_users,
    add_to_cart_users,
    checkout_users,
    purchase_users,
    1.0 * add_to_cart_users / NULLIF(view_product_users, 0) AS view_to_cart_conversion,
    1.0 * checkout_users / NULLIF(add_to_cart_users, 0) AS cart_to_checkout_conversion,
    1.0 * purchase_users / NULLIF(checkout_users, 0) AS checkout_to_purchase_conversion,
    1.0 * purchase_users / NULLIF(view_product_users, 0) AS view_to_purchase_conversion
FROM funnel
ORDER BY
    experiment_name,
    experiment_variant;


-- Mart 5: A/B test result metrics.
-- Orders and events are counted only after experiment assignment.

CREATE TABLE marts.mart_ab_test_result AS
WITH assigned_users AS (
    SELECT DISTINCT
        experiment_name,
        experiment_variant,
        user_sk,
        assigned_date_sk,
        assigned_at
    FROM dwh.fact_ab_assignments
),

base_users AS (
    SELECT
        experiment_name,
        experiment_variant,
        COUNT(DISTINCT user_sk) AS total_users
    FROM assigned_users
    GROUP BY
        experiment_name,
        experiment_variant
),

purchase_events AS (
    SELECT
        a.experiment_name,
        a.experiment_variant,
        COUNT(
            DISTINCT CASE WHEN e.event_type = 'purchase' THEN a.user_sk END
        ) AS purchase_users
    FROM assigned_users a
    LEFT JOIN dwh.fact_user_events e
        ON a.user_sk = e.user_sk
        AND e.event_time >= a.assigned_at
    GROUP BY
        a.experiment_name,
        a.experiment_variant
),

order_metrics AS (
    SELECT
        a.experiment_name,
        a.experiment_variant,
        COUNT(DISTINCT o.order_sk) AS total_orders,
        COALESCE(SUM(o.order_total_amount), 0) AS total_revenue
    FROM assigned_users a
    LEFT JOIN dwh.fact_orders o
        ON a.user_sk = o.user_sk
        AND o.order_status IN ('paid', 'delivered')
        AND o.order_date_sk >= a.assigned_date_sk
    GROUP BY
        a.experiment_name,
        a.experiment_variant
)

SELECT
    b.experiment_name,
    b.experiment_variant,
    b.total_users,
    COALESCE(p.purchase_users, 0) AS purchase_users,
    COALESCE(o.total_orders, 0) AS total_orders,
    COALESCE(o.total_revenue, 0) AS total_revenue,
    1.0 * COALESCE(p.purchase_users, 0) / NULLIF(b.total_users, 0) AS purchase_conversion,
    1.0 * COALESCE(o.total_revenue, 0) / NULLIF(o.total_orders, 0) AS avg_order_amount,
    1.0 * COALESCE(o.total_revenue, 0) / NULLIF(b.total_users, 0) AS revenue_per_user
FROM base_users b
LEFT JOIN purchase_events p
    ON b.experiment_name = p.experiment_name
    AND b.experiment_variant = p.experiment_variant
LEFT JOIN order_metrics o
    ON b.experiment_name = o.experiment_name
    AND b.experiment_variant = o.experiment_variant
ORDER BY
    b.experiment_name,
    b.experiment_variant;
