CREATE TABLE IF NOT EXISTS dwh.dim_users (
    user_sk BIGSERIAL PRIMARY KEY,
    external_user_id BIGINT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    birth_date DATE CHECK (birth_date <= CURRENT_DATE),
    city TEXT NOT NULL,
    registration_date DATE NOT NULL CHECK (registration_date <= CURRENT_DATE),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS dwh.dim_products (
    product_sk BIGSERIAL PRIMARY KEY,
    external_product_id BIGINT NOT NULL UNIQUE,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    base_price NUMERIC(10, 2) NOT NULL CHECK (base_price > 0),
    source_created_at DATE CHECK (source_created_at <= CURRENT_DATE),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS dwh.dim_dates (
    date_sk INTEGER PRIMARY KEY,
    date_actual DATE NOT NULL UNIQUE,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
    month_name TEXT NOT NULL,
    quarter INTEGER NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    day_of_month INTEGER NOT NULL CHECK (day_of_month BETWEEN 1 AND 31),
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    week_of_year INTEGER NOT NULL CHECK (week_of_year BETWEEN 1 AND 53),
    is_weekend BOOLEAN NOT NULL
);
