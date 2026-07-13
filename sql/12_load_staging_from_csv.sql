\copy staging.stg_users (user_id, name, birth_date, city, registration_date) FROM 'data/raw/users.csv' WITH (FORMAT csv, HEADER true);

UPDATE staging.stg_users
SET source_file_name = 'users.csv'
WHERE source_file_name IS NULL;


\copy staging.stg_products (product_id, product_name, category, base_price, created_at) FROM 'data/raw/products.csv' WITH (FORMAT csv, HEADER true);

UPDATE staging.stg_products
SET source_file_name = 'products.csv'
WHERE source_file_name IS NULL;


\copy staging.stg_orders (order_id, user_id, order_date, order_status, shipping_city, shipping_cost) FROM 'data/raw/orders.csv' WITH (FORMAT csv, HEADER true);

UPDATE staging.stg_orders
SET source_file_name = 'orders.csv'
WHERE source_file_name IS NULL;


\copy staging.stg_order_items (order_item_id, order_id, product_id, quantity, unit_price, line_total) FROM 'data/raw/order_items.csv' WITH (FORMAT csv, HEADER true);

UPDATE staging.stg_order_items
SET source_file_name = 'order_items.csv'
WHERE source_file_name IS NULL;


\copy staging.stg_user_events (event_id, user_id, event_type, event_time, product_id) FROM 'data/raw/user_events.csv' WITH (FORMAT csv, HEADER true);

UPDATE staging.stg_user_events
SET source_file_name = 'user_events.csv'
WHERE source_file_name IS NULL;


\copy staging.stg_ab_test_assignments (assignment_id, user_id, experiment_name, variant, assigned_at) FROM 'data/raw/ab_test_assignments.csv' WITH (FORMAT csv, HEADER true);

UPDATE staging.stg_ab_test_assignments
SET source_file_name = 'ab_test_assignments.csv'
WHERE source_file_name IS NULL;
