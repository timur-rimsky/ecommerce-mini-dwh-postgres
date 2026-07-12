CREATE TABLE IF NOT EXISTS clean.clean_users (
    user_id BIGINT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    birth_date DATE CHECK (birth_date <= CURRENT_DATE),
    city TEXT NOT NULL,
    registration_date DATE NOT NULL CHECK (registration_date <= CURRENT_DATE),
    source_staging_id BIGINT REFERENCES staging.stg_users(staging_id),
    loaded_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS clean.clean_products (
    product_id BIGINT NOT NULL UNIQUE,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    base_price NUMERIC(10, 2) NOT NULL CHECK (base_price > 0),
    created_at DATE CHECK (created_at <= CURRENT_DATE),
    source_staging_id BIGINT REFERENCES staging.stg_products(staging_id),
    loaded_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS clean.clean_orders (
    order_id BIGINT NOT NULL UNIQUE,
    user_id BIGINT NOT NULL REFERENCES clean.clean_users(user_id),
    order_date TIMESTAMP NOT NULL,
    order_status TEXT NOT NULL CHECK (
        order_status IN (
            'created',
            'paid',
            'cancelled',
            'refunded',
            'delivered'
        )
    ),
    shipping_city TEXT NOT NULL,
    shipping_cost NUMERIC(10, 2) NOT NULL CHECK (shipping_cost >= 0),
    source_staging_id BIGINT REFERENCES staging.stg_orders(staging_id),
    loaded_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS clean.clean_order_items (
    order_item_id BIGINT NOT NULL UNIQUE,
    order_id BIGINT NOT NULL REFERENCES clean.clean_orders(order_id),
    product_id BIGINT NOT NULL REFERENCES clean.clean_products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    line_total NUMERIC(10, 2) NOT NULL CHECK (line_total >= 0),
    source_staging_id BIGINT REFERENCES staging.stg_order_items(staging_id),
    loaded_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS clean.clean_user_events (
    event_id BIGINT NOT NULL UNIQUE,
    user_id BIGINT NOT NULL REFERENCES clean.clean_users(user_id),
    event_type TEXT NOT NULL CHECK (
        event_type IN (
            'view_product',
            'add_to_cart',
            'checkout',
            'purchase'
        )
    ),
    event_time TIMESTAMP NOT NULL,
    product_id BIGINT REFERENCES clean.clean_products(product_id),
    source_staging_id BIGINT REFERENCES staging.stg_user_events(staging_id),
    loaded_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS clean.clean_ab_test_assignments (
    assignment_id BIGINT NOT NULL UNIQUE,
    user_id BIGINT NOT NULL REFERENCES clean.clean_users(user_id),
    experiment_name TEXT NOT NULL,
    variant TEXT NOT NULL CHECK (variant IN ('A', 'B')),
    assigned_at TIMESTAMP NOT NULL,
    source_staging_id BIGINT REFERENCES staging.stg_ab_test_assignments(staging_id),
    loaded_at TIMESTAMP NOT NULL DEFAULT now()
);
