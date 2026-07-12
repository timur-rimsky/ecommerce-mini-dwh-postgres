CREATE TABLE IF NOT EXISTS staging.stg_users (
    staging_id BIGSERIAL PRIMARY KEY,
    source_file_name TEXT,
    loaded_at TIMESTAMP NOT NULL DEFAULT now(),
    user_id TEXT,
    name TEXT,
    birth_date TEXT,
    city TEXT,
    registration_date TEXT
);


CREATE TABLE IF NOT EXISTS staging.stg_products (
    staging_id BIGSERIAL PRIMARY KEY,
    source_file_name TEXT,
    loaded_at TIMESTAMP NOT NULL DEFAULT now(),
    product_id TEXT,
    product_name TEXT,
    category TEXT,
    base_price TEXT,
    created_at TEXT
);


CREATE TABLE IF NOT EXISTS staging.stg_orders (
    staging_id BIGSERIAL PRIMARY KEY,
    source_file_name TEXT,
    loaded_at TIMESTAMP NOT NULL DEFAULT now(),
    order_id TEXT,
    user_id TEXT,
    order_date TEXT,
    order_status TEXT,
    shipping_city TEXT,
    shipping_cost TEXT
);


CREATE TABLE IF NOT EXISTS staging.stg_order_items (
    staging_id BIGSERIAL PRIMARY KEY,
    source_file_name TEXT,
    loaded_at TIMESTAMP NOT NULL DEFAULT now(),
    order_item_id TEXT,
    order_id TEXT,
    product_id TEXT,
    quantity TEXT,
    unit_price TEXT,
    line_total TEXT
);


CREATE TABLE IF NOT EXISTS staging.stg_user_events (
    staging_id BIGSERIAL PRIMARY KEY,
    source_file_name TEXT,
    loaded_at TIMESTAMP NOT NULL DEFAULT now(),
    event_id TEXT,
    user_id TEXT,
    event_type TEXT,
    event_time TEXT,
    product_id TEXT
);


CREATE TABLE IF NOT EXISTS staging.stg_ab_test_assignments (
    staging_id BIGSERIAL PRIMARY KEY,
    source_file_name TEXT,
    loaded_at TIMESTAMP NOT NULL DEFAULT now(),
    assignment_id TEXT,
    user_id TEXT,
    experiment_name TEXT,
    variant TEXT,
    assigned_at TEXT
);
