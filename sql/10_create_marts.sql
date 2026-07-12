CREATE TABLE IF NOT EXISTS marts.mart_revenue_by_month AS
SELECT
    d.year AS year,
    d.month AS month,
    COUNT(o.order_sk) AS orders_count,
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


CREATE TABLE IF NOT EXISTS marts.mart_revenue_by_category AS
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
GROUP BY p.category
ORDER BY total_revenue DESC;


CREATE TABLE IF NOT EXISTS marts.mart_orders_by_city AS
SELECT
    shipping_city AS city,
    COUNT(order_sk) AS orders_count,
    SUM(order_total_amount) AS total_revenue,
    AVG(order_total_amount) AS avg_order_amount,
    SUM(shipping_cost) AS total_shipping_cost,
    AVG(shipping_cost) AS avg_shipping_cost
FROM dwh.fact_orders
WHERE order_status IN ('paid', 'delivered')
GROUP BY shipping_city
ORDER BY total_revenue DESC;


CREATE TABLE IF NOT EXISTS marts.mart_funnel_by_variant AS
WITH t AS (
    SELECT
        a.experiment_name AS experiment_name,
        a.experiment_variant AS experiment_variant,
        COUNT(
            DISTINCT CASE WHEN ue.event_type = 'view_product' THEN a.user_sk END
        ) AS view_product_users,
        COUNT(
            DISTINCT CASE WHEN ue.event_type = 'add_to_cart' THEN a.user_sk END
        ) AS add_to_cart_users,
        COUNT(
            DISTINCT CASE WHEN ue.event_type = 'checkout' THEN a.user_sk END
        ) AS checkout_users,
        COUNT(
            DISTINCT CASE WHEN ue.event_type = 'purchase' THEN a.user_sk END
        ) AS purchase_users
    FROM dwh.fact_ab_assignments a
    LEFT JOIN dwh.fact_user_events ue ON a.user_sk = ue.user_sk
    GROUP BY
        a.experiment_name,
        a.experiment_variant
)
SELECT
    t.experiment_name AS experiment_name,
    t.experiment_variant AS experiment_variant,
    t.view_product_users AS view_product_users,
    t.add_to_cart_users AS add_to_cart_users,
    t.checkout_users AS checkout_users,
    t.purchase_users AS purchase_users,
    1.0 * t.add_to_cart_users / NULLIF(t.view_product_users, 0) AS view_to_cart_conversion,
    1.0 * t.checkout_users / NULLIF(t.add_to_cart_users, 0) AS cart_to_checkout_conversion,
    1.0 * t.purchase_users / NULLIF(t.checkout_users, 0) AS checkout_to_purchase_conversion,
    1.0 * t.purchase_users / NULLIF(t.view_product_users, 0) AS view_to_purchase_conversion
FROM t;


CREATE TABLE IF NOT EXISTS marts.mart_ab_test_result AS
WITH base_users AS (
    SELECT
        experiment_name,
        experiment_variant,
        COUNT(DISTINCT user_sk) AS total_users
    FROM dwh.fact_ab_assignments
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
    FROM dwh.fact_ab_assignments a
    LEFT JOIN dwh.fact_user_events e ON a.user_sk = e.user_sk
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
    FROM dwh.fact_ab_assignments a
    LEFT JOIN dwh.fact_orders o
        ON a.user_sk = o.user_sk
        AND o.order_status IN ('paid', 'delivered')
    GROUP BY
        a.experiment_name,
        a.experiment_variant
)

SELECT
    b.experiment_name,
    b.experiment_variant,
    b.total_users,
    COALESCE(e.purchase_users, 0) AS purchase_users,
    COALESCE(m.total_orders, 0) AS total_orders,
    COALESCE(m.total_revenue, 0) AS total_revenue,
    1.0 * COALESCE(e.purchase_users, 0) / NULLIF(b.total_users, 0) AS purchase_conversion,
    1.0 * COALESCE(m.total_revenue, 0) / NULLIF(m.total_orders, 0) AS avg_order_amount,
    1.0 * COALESCE(m.total_revenue, 0) / NULLIF(b.total_users, 0) AS revenue_per_user
FROM base_users b
LEFT JOIN purchase_events e
    ON b.experiment_name = e.experiment_name
    AND b.experiment_variant = e.experiment_variant
LEFT JOIN order_metrics m
    ON b.experiment_name = m.experiment_name
    AND b.experiment_variant = m.experiment_variant
ORDER BY
    b.experiment_name,
    b.experiment_variant;
