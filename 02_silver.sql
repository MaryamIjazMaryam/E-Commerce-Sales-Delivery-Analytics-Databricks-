  CREATE OR REPLACE TABLE workspace.olist_silver.orders AS
SELECT
  order_id,
  customer_id,
  order_status,
  CAST(order_purchase_timestamp AS TIMESTAMP) AS purchase_ts,
  CAST(order_delivered_customer_date AS TIMESTAMP) AS delivered_ts,
  CAST(order_estimated_delivery_date AS TIMESTAMP) AS estimated_delivery_ts
FROM workspace.olist_bronze.orders
WHERE order_id IS NOT NULL;

CREATE OR REPLACE TABLE workspace.olist_silver.customers AS
SELECT customer_id, customer_unique_id, customer_city, customer_state
FROM workspace.olist_bronze.customers
WHERE customer_id IS NOT NULL;

CREATE OR REPLACE TABLE workspace.olist_silver.order_items AS
SELECT
  order_id,
  order_item_id,
  product_id,
  seller_id,
  CAST(price AS DECIMAL(10,2)) AS price,
  CAST(freight_value AS DECIMAL(10,2)) AS freight_value
FROM workspace.olist_bronze.order_items
WHERE order_id IS NOT NULL;

CREATE OR REPLACE TABLE workspace.olist_silver.products AS
SELECT
  p.product_id,
  COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category
FROM workspace.olist_bronze.products p
LEFT JOIN workspace.olist_bronze.category_translation t
  ON p.product_category_name = t.product_category_name
WHERE p.product_id IS NOT NULL;

CREATE OR REPLACE TABLE workspace.olist_silver.order_reviews AS
SELECT
  order_id,
  CAST(review_score AS INT) AS review_score
FROM workspace.olist_bronze.order_reviews
WHERE order_id IS NOT NULL
  AND CAST(review_score AS INT) BETWEEN 1 AND 5;

CREATE OR REPLACE TABLE workspace.olist_silver.order_payments AS
SELECT
  order_id,
  payment_type,
  CAST(payment_value AS DECIMAL(10,2)) AS payment_value
FROM workspace.olist_bronze.order_payments
WHERE order_id IS NOT NULL;
