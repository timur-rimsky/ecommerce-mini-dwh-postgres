CREATE INDEX IF NOT EXISTS idx_fact_orders_user
ON dwh.fact_orders (user_sk);

CREATE INDEX IF NOT EXISTS idx_fact_orders_date
ON dwh.fact_orders (order_date_sk);

CREATE INDEX IF NOT EXISTS idx_fact_orders_status
ON dwh.fact_orders (order_status);


CREATE INDEX IF NOT EXISTS idx_fact_order_items_order
ON dwh.fact_order_items (order_sk);

CREATE INDEX IF NOT EXISTS idx_fact_order_items_product
ON dwh.fact_order_items (product_sk);


CREATE INDEX IF NOT EXISTS idx_fact_user_events_user
ON dwh.fact_user_events (user_sk);

CREATE INDEX IF NOT EXISTS idx_fact_user_events_type
ON dwh.fact_user_events (event_type);


CREATE INDEX IF NOT EXISTS idx_fact_ab_assignments_user
ON dwh.fact_ab_assignments (user_sk);

CREATE INDEX IF NOT EXISTS idx_fact_ab_assignments_name_variant
ON dwh.fact_ab_assignments (experiment_name, experiment_variant);
