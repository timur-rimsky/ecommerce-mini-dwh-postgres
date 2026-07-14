-- Load fact tables from clean layer and dimension tables.
-- Fact tables use surrogate keys from DWH dimensions.


-- Load fact_orders
-- Grain: one row per order.
-- order_total_amount and items_count are calculated from clean.clean_order_items.

INSERT INTO dwh.fact_orders (
    external_order_id,
    user_sk,
    order_date_sk,
    order_status,
    shipping_city,
    shipping_cost,
    order_total_amount,
    items_count
)
SELECT
    o.order_id AS external_order_id,
    u.user_sk AS user_sk,
    d.date_sk AS order_date_sk,
    o.order_status AS order_status,
    o.shipping_city AS shipping_city,
    o.shipping_cost AS shipping_cost,
    SUM(oi.line_total) AS order_total_amount,
    COUNT(oi.order_item_id)::INTEGER AS items_count
FROM clean.clean_orders o
JOIN dwh.dim_users u ON o.user_id = u.external_user_id
JOIN dwh.dim_dates d ON o.order_date::DATE = d.date_actual
JOIN clean.clean_order_items oi ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    u.user_sk,
    d.date_sk,
    o.order_status,
    o.shipping_city,
    o.shipping_cost
ON CONFLICT (external_order_id) DO UPDATE
SET
    user_sk = EXCLUDED.user_sk,
    order_date_sk = EXCLUDED.order_date_sk,
    order_status = EXCLUDED.order_status,
    shipping_city = EXCLUDED.shipping_city,
    shipping_cost = EXCLUDED.shipping_cost,
    order_total_amount = EXCLUDED.order_total_amount,
    items_count = EXCLUDED.items_count,
    updated_at = now();


-- Load fact_order_items
-- Grain: one row per order line item.
-- Links each order item to order and product surrogate keys.

INSERT INTO dwh.fact_order_items (
    external_order_item_id,
    order_sk,
    product_sk,
    quantity,
    unit_price,
    line_total
)
SELECT
    oi.order_item_id AS external_order_item_id,
    o.order_sk AS order_sk,
    p.product_sk AS product_sk,
    oi.quantity AS quantity,
    oi.unit_price AS unit_price,
    oi.line_total AS line_total
FROM clean.clean_order_items oi
JOIN dwh.fact_orders o ON oi.order_id = o.external_order_id
JOIN dwh.dim_products p ON oi.product_id = p.external_product_id
ON CONFLICT (external_order_item_id) DO UPDATE
SET
    order_sk = EXCLUDED.order_sk,
    product_sk = EXCLUDED.product_sk,
    quantity = EXCLUDED.quantity,
    unit_price = EXCLUDED.unit_price,
    line_total = EXCLUDED.line_total,
    updated_at = now();


-- Load fact_user_events
-- Grain: one row per user event.
-- product_sk is nullable because not all events are product-level events.

INSERT INTO dwh.fact_user_events (
    external_event_id,
    user_sk,
    product_sk,
    event_date_sk,
    event_time,
    event_type
)
SELECT
    ue.event_id AS external_event_id,
    u.user_sk AS user_sk,
    p.product_sk AS product_sk,
    d.date_sk AS event_date_sk,
    ue.event_time AS event_time,
    ue.event_type AS event_type
FROM clean.clean_user_events ue
JOIN dwh.dim_users u ON ue.user_id = u.external_user_id
LEFT JOIN dwh.dim_products p ON ue.product_id = p.external_product_id
JOIN dwh.dim_dates d ON ue.event_time::DATE = d.date_actual
ON CONFLICT (external_event_id) DO UPDATE
SET
    user_sk = EXCLUDED.user_sk,
    product_sk = EXCLUDED.product_sk,
    event_date_sk = EXCLUDED.event_date_sk,
    event_time = EXCLUDED.event_time,
    event_type = EXCLUDED.event_type;


-- Load fact_ab_assignments
-- Grain: one row per user assignment to an A/B test variant.

INSERT INTO dwh.fact_ab_assignments (
    external_assignment_id,
    user_sk,
    assigned_date_sk,
    experiment_name,
    experiment_variant,
    assigned_at
)
SELECT
    a.assignment_id AS external_assignment_id,
    u.user_sk AS user_sk,
    d.date_sk AS assigned_date_sk,
    a.experiment_name AS experiment_name,
    a.variant AS experiment_variant,
    a.assigned_at AS assigned_at
FROM clean.clean_ab_test_assignments a
JOIN dwh.dim_users u ON a.user_id = u.external_user_id
JOIN dwh.dim_dates d ON a.assigned_at::DATE = d.date_actual
ON CONFLICT (external_assignment_id) DO UPDATE
SET
    user_sk = EXCLUDED.user_sk,
    assigned_date_sk = EXCLUDED.assigned_date_sk,
    experiment_name = EXCLUDED.experiment_name,
    experiment_variant = EXCLUDED.experiment_variant,
    assigned_at = EXCLUDED.assigned_at;
