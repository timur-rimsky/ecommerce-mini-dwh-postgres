-- Data Quality Checks for E-commerce Mini DWH.
-- Each query returns problematic rows.
-- Expected result for a successful run: 0 rows for each check.


-- ============================================================
-- Dimension checks: dwh.dim_users
-- ============================================================

-- Check 1: duplicate external_user_id
SELECT
    external_user_id,
    COUNT(*) AS duplicates_count
FROM dwh.dim_users
GROUP BY external_user_id
HAVING COUNT(*) > 1;


-- Check 2: missing required fields
SELECT
    user_sk,
    external_user_id,
    name,
    city,
    registration_date
FROM dwh.dim_users
WHERE
    external_user_id IS NULL OR
    name IS NULL OR
    TRIM(name) = '' OR
    city IS NULL OR
    TRIM(city) = '' OR
    registration_date IS NULL;


-- Check 3: dates from future
SELECT
    user_sk,
    name,
    birth_date,
    registration_date
FROM dwh.dim_users
WHERE
    birth_date > CURRENT_DATE OR
    registration_date > CURRENT_DATE;


-- Check 4: update before create
SELECT
    user_sk,
    name,
    created_at,
    updated_at
FROM dwh.dim_users
WHERE updated_at < created_at;


-- ============================================================
-- Dimension checks: dwh.dim_products
-- ============================================================

-- Check 5: duplicate external_product_id
SELECT
    external_product_id,
    COUNT(*) AS duplicates_count
FROM dwh.dim_products
GROUP BY external_product_id
HAVING COUNT(*) > 1;


-- Check 6: missing required fields
SELECT
    product_sk,
    external_product_id,
    product_name,
    category,
    base_price
FROM dwh.dim_products
WHERE
    external_product_id IS NULL OR
    product_name IS NULL OR
    TRIM(product_name) = '' OR
    category IS NULL OR
    TRIM(category) = '' OR
    base_price IS NULL;


-- Check 7: invalid price
SELECT
    product_sk,
    product_name,
    base_price
FROM dwh.dim_products
WHERE base_price <= 0;


-- Check 8: dates from future
SELECT
    product_sk,
    product_name,
    source_created_at
FROM dwh.dim_products
WHERE source_created_at > CURRENT_DATE;


-- Check 9: update before create
SELECT
    product_sk,
    product_name,
    created_at,
    updated_at
FROM dwh.dim_products
WHERE updated_at < created_at;


-- ============================================================
-- Fact checks: dwh.fact_orders
-- ============================================================

-- Check 10: duplicate external_order_id
SELECT
    external_order_id,
    COUNT(*) AS duplicates_count
FROM dwh.fact_orders
GROUP BY external_order_id
HAVING COUNT(*) > 1;


-- Check 11: missing required fields
SELECT
    order_sk,
    external_order_id,
    user_sk,
    order_date_sk,
    order_status,
    shipping_city,
    shipping_cost,
    order_total_amount,
    items_count
FROM dwh.fact_orders
WHERE
    external_order_id IS NULL OR
    user_sk IS NULL OR
    order_date_sk IS NULL OR
    order_status IS NULL OR
    shipping_city IS NULL OR
    TRIM(shipping_city) = '' OR
    shipping_cost IS NULL OR
    order_total_amount IS NULL OR
    items_count IS NULL;


-- Check 12: invalid order_status
SELECT
    order_sk,
    order_status
FROM dwh.fact_orders
WHERE order_status NOT IN (
    'created',
    'paid',
    'cancelled',
    'refunded',
    'delivered'
);


-- Check 13: invalid numeric values
SELECT
    order_sk,
    shipping_cost,
    order_total_amount,
    items_count
FROM dwh.fact_orders
WHERE
    shipping_cost < 0 OR
    order_total_amount < 0 OR
    items_count <= 0;


-- Check 14: update before create
SELECT
    order_sk,
    created_at,
    updated_at
FROM dwh.fact_orders
WHERE updated_at < created_at;


-- Check 15: valid reference surrogate keys
SELECT
    o.order_sk,
    o.user_sk,
    u.user_sk AS matched_user_sk,
    o.order_date_sk,
    d.date_sk AS matched_date_sk
FROM dwh.fact_orders o
LEFT JOIN dwh.dim_users u ON o.user_sk = u.user_sk
LEFT JOIN dwh.dim_dates d ON o.order_date_sk = d.date_sk
WHERE
    u.user_sk IS NULL OR
    d.date_sk IS NULL;


-- ============================================================
-- Fact checks: dwh.fact_order_items
-- ============================================================

-- Check 16: duplicate external_order_item_id
SELECT
    external_order_item_id,
    COUNT(*) AS duplicates_count
FROM dwh.fact_order_items
GROUP BY external_order_item_id
HAVING COUNT(*) > 1;


-- Check 17: missing required fields
SELECT
    order_item_sk,
    external_order_item_id,
    order_sk,
    product_sk,
    quantity,
    unit_price,
    line_total
FROM dwh.fact_order_items
WHERE
    external_order_item_id IS NULL OR
    order_sk IS NULL OR
    product_sk IS NULL OR
    quantity IS NULL OR
    unit_price IS NULL OR
    line_total IS NULL;


-- Check 18: invalid numeric values
SELECT
    order_item_sk,
    quantity,
    unit_price,
    line_total
FROM dwh.fact_order_items
WHERE
    quantity <= 0 OR
    unit_price <= 0 OR
    line_total < 0;


-- Check 19: invalid line_total calculation
SELECT
    order_item_sk,
    quantity,
    unit_price,
    line_total,
    quantity * unit_price AS expected_line_total,
    ABS(line_total - quantity * unit_price) AS calculation_error
FROM dwh.fact_order_items
WHERE ABS(line_total - quantity * unit_price) > 0.01;


-- Check 20: update before create
SELECT
    order_item_sk,
    created_at,
    updated_at
FROM dwh.fact_order_items
WHERE updated_at < created_at;


-- Check 21: valid reference surrogate keys
SELECT
    oi.order_item_sk,
    oi.order_sk,
    o.order_sk AS matched_order_sk,
    oi.product_sk,
    p.product_sk AS matched_product_sk
FROM dwh.fact_order_items oi
LEFT JOIN dwh.fact_orders o ON oi.order_sk = o.order_sk
LEFT JOIN dwh.dim_products p ON oi.product_sk = p.product_sk
WHERE
    o.order_sk IS NULL OR
    p.product_sk IS NULL;


-- ============================================================
-- Fact checks: dwh.fact_user_events
-- ============================================================

-- Check 22: duplicate external_event_id
SELECT
    external_event_id,
    COUNT(*) AS duplicates_count
FROM dwh.fact_user_events
GROUP BY external_event_id
HAVING COUNT(*) > 1;


-- Check 23: missing required fields
SELECT
    event_sk,
    external_event_id,
    user_sk,
    event_date_sk,
    event_time,
    event_type,
    event_count
FROM dwh.fact_user_events
WHERE
    external_event_id IS NULL OR
    user_sk IS NULL OR
    event_date_sk IS NULL OR
    event_time IS NULL OR
    event_type IS NULL OR
    TRIM(event_type) = '' OR
    event_count IS NULL;


-- Check 24: invalid event_type
SELECT
    event_sk,
    event_type
FROM dwh.fact_user_events
WHERE event_type NOT IN (
    'view_product',
    'add_to_cart',
    'checkout',
    'purchase'
);


-- Check 25: invalid event_count
SELECT
    event_sk,
    event_count
FROM dwh.fact_user_events
WHERE event_count <> 1;


-- Check 26: valid reference surrogate keys
SELECT
    e.event_sk,
    e.user_sk,
    u.user_sk AS matched_user_sk,
    e.product_sk,
    p.product_sk AS matched_product_sk,
    e.event_date_sk,
    d.date_sk AS matched_date_sk
FROM dwh.fact_user_events e
LEFT JOIN dwh.dim_users u ON e.user_sk = u.user_sk
LEFT JOIN dwh.dim_products p ON e.product_sk = p.product_sk
LEFT JOIN dwh.dim_dates d ON e.event_date_sk = d.date_sk
WHERE
    u.user_sk IS NULL OR
    (e.product_sk IS NOT NULL AND p.product_sk IS NULL) OR
    d.date_sk IS NULL;


-- ============================================================
-- Fact checks: dwh.fact_ab_assignments
-- ============================================================

-- Check 27: duplicate external_assignment_id
SELECT
    external_assignment_id,
    COUNT(*) AS duplicates_count
FROM dwh.fact_ab_assignments
GROUP BY external_assignment_id
HAVING COUNT(*) > 1;


-- Check 28: missing required fields
SELECT
    assignment_sk,
    external_assignment_id,
    user_sk,
    assigned_date_sk,
    experiment_name,
    experiment_variant,
    assigned_at,
    assignment_count
FROM dwh.fact_ab_assignments
WHERE
    external_assignment_id IS NULL OR
    user_sk IS NULL OR
    assigned_date_sk IS NULL OR
    experiment_name IS NULL OR
    TRIM(experiment_name) = '' OR
    experiment_variant IS NULL OR
    TRIM(experiment_variant) = '' OR
    assigned_at IS NULL OR
    assignment_count IS NULL;


-- Check 29: invalid experiment_variant
SELECT
    assignment_sk,
    experiment_variant
FROM dwh.fact_ab_assignments
WHERE experiment_variant NOT IN ('A', 'B');


-- Check 30: invalid assignment_count
SELECT
    assignment_sk,
    assignment_count
FROM dwh.fact_ab_assignments
WHERE assignment_count <> 1;


-- Check 31: valid reference surrogate keys
SELECT
    a.assignment_sk,
    a.user_sk,
    u.user_sk AS matched_user_sk,
    a.assigned_date_sk,
    d.date_sk AS matched_date_sk
FROM dwh.fact_ab_assignments a
LEFT JOIN dwh.dim_users u ON a.user_sk = u.user_sk
LEFT JOIN dwh.dim_dates d ON a.assigned_date_sk = d.date_sk
WHERE
    u.user_sk IS NULL OR
    d.date_sk IS NULL;
