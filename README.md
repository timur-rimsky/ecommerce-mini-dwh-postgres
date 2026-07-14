# E-commerce Mini DWH on PostgreSQL

Mini data warehouse project for e-commerce analytics built with PostgreSQL and SQL.

## Project Status

**MVP completed**

The project includes a full SQL-based data pipeline:

```text
CSV raw data
    ↓
staging layer
    ↓
clean / ODS layer
    ↓
DWH layer
    ├── dimension tables
    └── fact tables
    ↓
analytical marts
    ↓
data quality checks
```

## Goal

The goal of this project is to design and implement a small analytical data warehouse for e-commerce data.

The project demonstrates:

- layered DWH architecture;
- staging and clean data layers;
- dimensional modeling;
- surrogate keys;
- dimension and fact tables;
- SQL transformations;
- analytical marts;
- data quality checks;
- CSV-based data loading.

## Tech Stack

- PostgreSQL
- SQL
- Data Warehouse design
- Dimensional modeling
- Data Quality
- CSV data loading

## Project Structure

```text
ecommerce-mini-dwh-postgres/
├── data/
│   └── raw/
│       ├── users.csv
│       ├── products.csv
│       ├── orders.csv
│       ├── order_items.csv
│       ├── user_events.csv
│       └── ab_test_assignments.csv
├── sql/
│   ├── 01_create_schemas.sql
│   ├── 02_create_staging_tables.sql
│   ├── 03_create_clean_tables.sql
│   ├── 04_create_dwh_dimensions.sql
│   ├── 05_create_dwh_facts.sql
│   ├── 06_generate_dim_dates.sql
│   ├── 07_load_dwh_dimensions.sql
│   ├── 08_load_dwh_facts.sql
│   ├── 09_create_indexes.sql
│   ├── 10_create_marts.sql
│   ├── 11_data_quality_checks.sql
│   ├── 12_load_staging_from_csv.sql
│   └── 13_load_clean_from_staging.sql
├── README.md
├── .gitignore
└── .gitattributes
```

## Source Data

The project uses six CSV files:

| File | Description |
|---|---|
| `users.csv` | User data |
| `products.csv` | Product catalog |
| `orders.csv` | Orders |
| `order_items.csv` | Order line items |
| `user_events.csv` | User behavior events |
| `ab_test_assignments.csv` | A/B test assignments |

## Database Layers

### Staging Layer

Schema:

```text
staging
```

The staging layer stores raw CSV data mostly as text.

Tables:

```text
staging.stg_users
staging.stg_products
staging.stg_orders
staging.stg_order_items
staging.stg_user_events
staging.stg_ab_test_assignments
```

### Clean Layer

Schema:

```text
clean
```

The clean layer stores validated and typed data.

Examples of transformations:

```text
TEXT → BIGINT
TEXT → DATE
TEXT → TIMESTAMP
TEXT → NUMERIC
TEXT → INTEGER
```

Tables:

```text
clean.clean_users
clean.clean_products
clean.clean_orders
clean.clean_order_items
clean.clean_user_events
clean.clean_ab_test_assignments
```

### DWH Layer

Schema:

```text
dwh
```

Dimension tables:

```text
dwh.dim_users
dwh.dim_products
dwh.dim_dates
```

Fact tables:

```text
dwh.fact_orders
dwh.fact_order_items
dwh.fact_user_events
dwh.fact_ab_assignments
```

## Analytical Marts

Schema:

```text
marts
```

The project includes the following analytical marts:

```text
marts.mart_revenue_by_month
marts.mart_revenue_by_category
marts.mart_orders_by_city
marts.mart_funnel_by_variant
marts.mart_ab_test_result
```

### Mart Examples

`mart_revenue_by_month` shows:

- year;
- month;
- number of successful orders;
- total revenue;
- average order value.

`mart_revenue_by_category` shows:

- product category;
- total revenue;
- number of orders;
- total quantity sold;
- average item price.

`mart_orders_by_city` shows:

- shipping city;
- number of successful orders;
- total revenue;
- average order amount;
- total shipping cost;
- average shipping cost.

`mart_funnel_by_variant` shows user funnel metrics by A/B test variant:

- product views;
- add to cart;
- checkout;
- purchase;
- conversion rates between funnel steps.

`mart_ab_test_result` shows A/B test results:

- total users;
- purchase users;
- total orders;
- total revenue;
- purchase conversion;
- average order amount;
- revenue per user.

## How to Run

This project is intended to be run on a clean PostgreSQL database.

The staging CSV load appends data, so for a clean end-to-end run it is recommended to recreate the database before running the scripts.

Create the database:

```bash
createdb -h localhost -p 5432 -U postgres ecommerce_dwh
```

Run SQL files in this order:

```bash
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/01_create_schemas.sql
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/02_create_staging_tables.sql
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/03_create_clean_tables.sql
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/04_create_dwh_dimensions.sql
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/05_create_dwh_facts.sql
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/06_generate_dim_dates.sql

psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/12_load_staging_from_csv.sql
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/13_load_clean_from_staging.sql
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/07_load_dwh_dimensions.sql
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/08_load_dwh_facts.sql
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/09_create_indexes.sql
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/10_create_marts.sql
psql -h localhost -p 5432 -U postgres -d ecommerce_dwh -f sql/11_data_quality_checks.sql
```

For a full rerun, recreate the database first:

```bash
dropdb -h localhost -p 5432 -U postgres ecommerce_dwh
createdb -h localhost -p 5432 -U postgres ecommerce_dwh
```

## Expected Row Counts

### Staging

```text
stg_users                  10
stg_products                8
stg_orders                 15
stg_order_items            25
stg_user_events            45
stg_ab_test_assignments    10
```

### Clean

```text
clean_users                  10
clean_products                8
clean_orders                 15
clean_order_items            25
clean_user_events            45
clean_ab_test_assignments    10
```

### DWH

```text
dim_users       10
dim_products     8
dim_dates      2922

fact_orders          15
fact_order_items     25
fact_user_events     45
fact_ab_assignments  10
```

### Marts

```text
mart_revenue_by_month       2
mart_revenue_by_category    5
mart_orders_by_city         7
mart_funnel_by_variant      2
mart_ab_test_result         2
```

## Data Quality Checks

The project includes SQL checks for:

- duplicate business keys;
- missing required fields;
- invalid order statuses;
- invalid event types;
- invalid A/B test variants;
- negative numeric values;
- incorrect line total calculations;
- broken references between fact and dimension tables;
- invalid technical timestamps.

A successful result means that the data quality queries return no problematic rows.

## Current Result

The project was successfully executed end-to-end:

```text
CSV → staging → clean → DWH → marts → data quality checks
```

All data quality checks returned zero problematic rows.

## Future Improvements

Possible future improvements:

- Docker Compose setup for PostgreSQL;
- Python-based CSV loading;
- automated pipeline runner;
- dbt implementation;
- additional tests;
- larger synthetic dataset;
- dashboard layer.
