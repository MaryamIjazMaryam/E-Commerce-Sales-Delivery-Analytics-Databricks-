-- Q1: How does monthly revenue change, and what is the growth %?
-- Insight: Sales grew strongly through 2017 and peaked around November 2017 (Black Friday).
WITH monthly AS (
  SELECT DATE_TRUNC('month', purchase_ts) AS month,
         SUM(revenue) AS revenue
  FROM workspace.olist_gold.order_facts
  GROUP BY 1
)
SELECT month,
       ROUND(revenue, 0) AS revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month) * 100, 1) AS growth_pct
FROM monthly
ORDER BY month;

-- Q2: What is the running total of revenue?
-- Insight: Total revenue reached about 13.2 million over the period.
WITH monthly AS (
  SELECT DATE_TRUNC('month', purchase_ts) AS month,
         SUM(revenue) AS revenue
  FROM workspace.olist_gold.order_facts
  GROUP BY 1
)
SELECT month,
       ROUND(revenue, 0) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 0) AS running_total
FROM monthly
ORDER BY month;

-- Q3: Which 10 product categories make the most money?
-- Insight: (write the top categories YOUR result showed, e.g. health_beauty, watches_gifts)
SELECT category, orders, ROUND(revenue, 0) AS revenue
FROM workspace.olist_gold.category_sales
ORDER BY revenue DESC
LIMIT 10;

-- Q4: Which states have the most late deliveries?
-- Insight: Far-away northern and northeastern states have higher late rates than Sao Paulo (SP).
SELECT customer_state,
       COUNT(*) AS orders,
       ROUND(AVG(is_late) * 100, 1) AS late_percent,
       ROUND(AVG(delivery_days), 1) AS avg_days
FROM workspace.olist_gold.order_facts
GROUP BY customer_state
ORDER BY late_percent DESC;

-- Q5: Do late deliveries get worse reviews?
-- Insight: (write YOUR numbers: on-time average vs late average stars)
SELECT
  CASE WHEN is_late = 1 THEN 'Late' ELSE 'On time' END AS delivery,
  COUNT(*) AS orders,
  ROUND(AVG(review_score), 2) AS avg_review
FROM workspace.olist_gold.order_facts
WHERE review_score IS NOT NULL
GROUP BY is_late;

-- Q6: How many customers ordered more than once?
-- Insight: (write YOUR percent) Almost all customers ordered only once, so winning back customers is a big opportunity.
WITH per_customer AS (
  SELECT customer_unique_id, COUNT(*) AS order_count
  FROM workspace.olist_gold.order_facts
  GROUP BY customer_unique_id
)
SELECT
  CASE WHEN order_count = 1 THEN 'One order' ELSE 'Repeat customer' END AS customer_type,
  COUNT(*) AS customers,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percent
FROM per_customer
GROUP BY 1;

-- Q7: Which 3 states make the most money?
-- Insight: SP is first by a large margin, followed by RJ and MG.
SELECT customer_state, ROUND(revenue, 0) AS revenue, rnk
FROM (
  SELECT customer_state,
         SUM(revenue) AS revenue,
         RANK() OVER (ORDER BY SUM(revenue) DESC) AS rnk
  FROM workspace.olist_gold.order_facts
  GROUP BY customer_state
)
WHERE rnk <= 3;