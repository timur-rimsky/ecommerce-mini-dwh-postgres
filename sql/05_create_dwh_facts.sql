CREATE TABLE IF NOT EXISTS dwh.fact_orders (
    order_sk BIGSERIAL PRIMARY KEY,
    external_order_id BIGINT NOT NULL UNIQUE,
    user_sk BIGINT NOT NULL REFERENCES dwh.dim_users(user_sk),
    order_date_sk INTEGER NOT NULL REFERENCES dwh.dim_dates(date_sk),
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
    order_total_amount NUMERIC(10, 2) NOT NULL CHECK (order_total_amount >= 0),
    items_count INTEGER NOT NULL CHECK (items_count > 0),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS dwh.fact_order_items (
    order_item_sk BIGSERIAL PRIMARY KEY,
    external_order_item_id BIGINT NOT NULL UNIQUE,
    order_sk BIGINT NOT NULL REFERENCES dwh.fact_orders(order_sk),
    product_sk BIGINT NOT NULL REFERENCES dwh.dim_products(product_sk),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    line_total NUMERIC(10, 2) NOT NULL CHECK (line_total >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS dwh.fact_user_events (
    event_sk BIGSERIAL PRIMARY KEY,
    external_event_id BIGINT NOT NULL UNIQUE,
    user_sk BIGINT NOT NULL REFERENCES dwh.dim_users(user_sk),
    product_sk BIGINT REFERENCES dwh.dim_products(product_sk),
    event_date_sk INTEGER NOT NULL REFERENCES dwh.dim_dates(date_sk),
    event_time TIMESTAMP NOT NULL,
    event_type TEXT NOT NULL CHECK (
        event_type IN (
            'view_product',
            'add_to_cart',
            'checkout',
            'purchase'
        )
    ),
    event_count INTEGER NOT NULL DEFAULT 1 CHECK (event_count = 1),
    created_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS dwh.fact_ab_assignments (
    assignment_sk BIGSERIAL PRIMARY KEY,
    external_assignment_id BIGINT NOT NULL UNIQUE,
    user_sk BIGINT NOT NULL REFERENCES dwh.dim_users(user_sk),
    assigned_date_sk INTEGER NOT NULL REFERENCES dwh.dim_dates(date_sk),
    experiment_name TEXT NOT NULL,
    experiment_variant TEXT NOT NULL CHECK (
        experiment_variant IN (
            'A',
            'B'
        )
    ),
    assigned_at TIMESTAMP NOT NULL,
    assignment_count INTEGER NOT NULL DEFAULT 1 CHECK (assignment_count = 1),
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
