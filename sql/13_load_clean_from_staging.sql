-- Load data from staging layer to clean layer.
-- This step converts raw TEXT values into typed and validated clean tables.
-- Clean tables keep source_staging_id for basic data lineage.


-- Load clean users
INSERT INTO clean.clean_users (
    user_id,
    name,
    birth_date,
    city,
    registration_date,
    source_staging_id
)
SELECT
    user_id::BIGINT,
    TRIM(name),
    birth_date::DATE,
    TRIM(city),
    registration_date::DATE,
    staging_id AS source_staging_id
FROM staging.stg_users
ON CONFLICT (user_id) DO UPDATE
SET
    name = EXCLUDED.name,
    birth_date = EXCLUDED.birth_date,
    city = EXCLUDED.city,
    registration_date = EXCLUDED.registration_date,
    source_staging_id = EXCLUDED.source_staging_id,
    loaded_at = now();


-- Load clean products
INSERT INTO clean.clean_products (
    product_id,
    product_name,
    category,
    base_price,
    created_at,
    source_staging_id
)
SELECT
    product_id::BIGINT,
    TRIM(product_name),
    TRIM(category),
    base_price::NUMERIC(10, 2),
    created_at::DATE,
    staging_id AS source_staging_id
FROM staging.stg_products
ON CONFLICT (product_id) DO UPDATE
SET
    product_name = EXCLUDED.product_name,
    category = EXCLUDED.category,
    base_price = EXCLUDED.base_price,
    created_at = EXCLUDED.created_at,
    source_staging_id = EXCLUDED.source_staging_id,
    loaded_at = now();


-- Load clean orders
INSERT INTO clean.clean_orders (
    order_id,
    user_id,
    order_date,
    order_status,
    shipping_city,
    shipping_cost,
    source_staging_id
)
SELECT
    order_id::BIGINT,
    user_id::BIGINT,
    order_date::TIMESTAMP,
    TRIM(order_status),
    TRIM(shipping_city),
    shipping_cost::NUMERIC(10, 2),
    staging_id AS source_staging_id
FROM staging.stg_orders
ON CONFLICT (order_id) DO UPDATE
SET
    user_id = EXCLUDED.user_id,
    order_date = EXCLUDED.order_date,
    order_status = EXCLUDED.order_status,
    shipping_city = EXCLUDED.shipping_city,
    shipping_cost = EXCLUDED.shipping_cost,
    source_staging_id = EXCLUDED.source_staging_id,
    loaded_at = now();


-- Load clean order items
INSERT INTO clean.clean_order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    line_total,
    source_staging_id
)
SELECT
    order_item_id::BIGINT,
    order_id::BIGINT,
    product_id::BIGINT,
    quantity::INTEGER,
    unit_price::NUMERIC(10, 2),
    line_total::NUMERIC(10, 2),
    staging_id AS source_staging_id
FROM staging.stg_order_items
ON CONFLICT (order_item_id) DO UPDATE
SET
    order_id = EXCLUDED.order_id,
    product_id = EXCLUDED.product_id,
    quantity = EXCLUDED.quantity,
    unit_price = EXCLUDED.unit_price,
    line_total = EXCLUDED.line_total,
    source_staging_id = EXCLUDED.source_staging_id,
    loaded_at = now();


-- Load clean user events
-- product_id can be empty for checkout and purchase events.
-- Empty product_id values are converted to NULL.

INSERT INTO clean.clean_user_events (
    event_id,
    user_id,
    event_type,
    event_time,
    product_id,
    source_staging_id
)
SELECT
    event_id::BIGINT,
    user_id::BIGINT,
    TRIM(event_type),
    event_time::TIMESTAMP,
    NULLIF(TRIM(product_id), '')::BIGINT,
    staging_id AS source_staging_id
FROM staging.stg_user_events
ON CONFLICT (event_id) DO UPDATE
SET
    user_id = EXCLUDED.user_id,
    event_type = EXCLUDED.event_type,
    event_time = EXCLUDED.event_time,
    product_id = EXCLUDED.product_id,
    source_staging_id = EXCLUDED.source_staging_id,
    loaded_at = now();


-- Load clean A/B test assignments
INSERT INTO clean.clean_ab_test_assignments (
    assignment_id,
    user_id,
    experiment_name,
    variant,
    assigned_at,
    source_staging_id
)
SELECT
    assignment_id::BIGINT,
    user_id::BIGINT,
    TRIM(experiment_name),
    TRIM(variant),
    assigned_at::TIMESTAMP,
    staging_id AS source_staging_id
FROM staging.stg_ab_test_assignments
ON CONFLICT (assignment_id) DO UPDATE
SET
    user_id = EXCLUDED.user_id,
    experiment_name = EXCLUDED.experiment_name,
    variant = EXCLUDED.variant,
    assigned_at = EXCLUDED.assigned_at,
    source_staging_id = EXCLUDED.source_staging_id,
    loaded_at = now();
