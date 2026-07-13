# E-commerce Mini DWH on PostgreSQL

Mini data warehouse project for e-commerce analytics built with PostgreSQL and SQL.

> Project status: **in progress**

## Goal

The goal of this project is to design a small analytical data warehouse for e-commerce data and build SQL-based analytical marts.

The project demonstrates:

* staging, clean, DWH and marts layers;
* dimensional modeling with dimension and fact tables;
* primary and foreign keys;
* surrogate keys;
* SQL transformations;
* analytical marts;
* data quality checks.

## General Architecture

```text
CSV raw data
    ↓
staging layer
    ↓
clean / ODS layer
    ↓
DWH layer
    ├── dimensions
    └── facts
    ↓
analytical marts
```

## Data Model

Main entities:

```text
users
products
orders
order_items
user_events
ab_test_assignments
```

DWH layer:

```text
dwh.dim_users
dwh.dim_products
dwh.dim_dates

dwh.fact_orders
dwh.fact_order_items
dwh.fact_user_events
dwh.fact_ab_assignments
```

## Analytical Marts

The project includes analytical marts for:

* revenue by month;
* revenue by product category;
* orders and revenue by city;
* user funnel by A/B test variant;
* A/B test result metrics.

## Current Focus

The project is currently focused on SQL and DWH design:

* database schemas;
* staging and clean tables;
* dimension and fact tables;
* SQL-based transformations;
* analytical marts;
* data quality checks.

Future improvements may include automated data loading, orchestration, tests and Docker-based runtime.

## Tech Stack

* PostgreSQL
* SQL
* Data Warehouse design
* Dimensional modeling
* Data Quality
