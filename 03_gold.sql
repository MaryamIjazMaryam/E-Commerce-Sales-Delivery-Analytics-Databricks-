-- Gold table 1: one row per delivered order
-- (revenue, delivery time, late flag, review score)
CREATE OR REPLACE TABLE workspace.olist_gold.order_facts AS
WITH items AS (
  SELECT order_id,
         SUM(price) AS revenue,
         SUM(freight_value) AS freight
  FROM workspace.olist_silver.order_items
  GROUP BY order_id
),
reviews AS (
  SELECT order_id, AVG(review_score) AS review_score
  FROM workspace.olist_silver.order_reviews
  GROUP BY order_id
)
SELECT
  o.order_id,
  c.customer_unique_id,
  c.customer_state,
  o.purchase_ts,
  i.revenue,
  i.freight,
  DATEDIFF(o.delivered_ts, o.purchase_ts) AS delivery_days,
  CASE WHEN o.delivered_ts > o.estimated_delivery_ts THEN 1 ELSE 0 END AS is_late,
  r.review_score
FROM workspace.olist_silver.orders o
JOIN workspace.olist_silver.customers c ON o.customer_id = c.customer_id
JOIN items i ON o.order_id = i.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.delivered_ts IS NOT NULL;

-- Gold table 2: sales by product category
CREATE OR REPLACE TABLE workspace.olist_gold.category_sales AS
SELECT
  p.category,
  COUNT(DISTINCT i.order_id) AS orders,
  SUM(i.price) AS revenue
FROM workspace.olist_silver.order_items i
JOIN workspace.olist_silver.products p ON i.product_id = p.product_id
JOIN workspace.olist_silver.orders o ON i.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.category;