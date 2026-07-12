INSERT INTO dwh.dim_users (
    external_user_id,
    name,
    birth_date,
    city,
    registration_date
)
SELECT
    user_id AS external_user_id,
    name,
    birth_date,
    city,
    registration_date
FROM clean.clean_users
ON CONFLICT (external_user_id) DO UPDATE
SET
    name = EXCLUDED.name,
    birth_date = EXCLUDED.birth_date,
    city = EXCLUDED.city,
    registration_date = EXCLUDED.registration_date,
    updated_at = now();


INSERT INTO dwh.dim_products (
    external_product_id,
    product_name,
    category,
    base_price,
    source_created_at
)
SELECT
    product_id AS external_product_id,
    product_name,
    category,
    base_price,
    created_at AS source_created_at
FROM clean.clean_products
ON CONFLICT (external_product_id) DO UPDATE
SET
    product_name = EXCLUDED.product_name,
    category = EXCLUDED.category,
    base_price = EXCLUDED.base_price,
    source_created_at = EXCLUDED.source_created_at,
    updated_at = now();
