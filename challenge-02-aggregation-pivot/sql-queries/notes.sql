-- Challenge 02: Aggregation & SQL Pivot Table
-- Notes + queries

-------------------------------
-- 1) Stock Aggregation
-------------------------------

-- Global metrics
SELECT COUNT(product_id) AS total_products
FROM `course15.circle_stock_kpi`;

SELECT COUNTIF(in_stock="0") * 1.0 / COUNT(product_id) AS shortage_rate
FROM `course15.circle_stock_kpi`;

SELECT SUM(stock_value) AS total_stock_value
FROM `course15.circle_stock_kpi`;

SELECT SUM(stock) AS total_stock
FROM `course15.circle_stock_kpi`;

-- Aggregated by model_type
SELECT model_type, COUNT(product_id) AS total_products
FROM `course15.circle_stock_kpi`
GROUP BY model_type;

SELECT model_type, SUM(stock_value) AS total_stock_value
FROM `course15.circle_stock_kpi`
GROUP BY model_type;

-- Aggregated by model_type + model_name
SELECT
  model_type,
  model_name,
  COUNT(product_id) AS total_products,
  SUM(stock_value) AS total_stock_value
FROM `course15.circle_stock_kpi`
GROUP BY model_type, model_name
ORDER BY total_stock_value DESC;

-------------------------------
-- 2) Sales Aggregation
-------------------------------

-- Top 10 products sold
SELECT
  product_id,
  SUM(qty) AS qty
FROM `course15.circle_sales`
GROUP BY product_id
ORDER BY qty DESC
LIMIT 10;

-- Flag top products
SELECT
  *,
  0 AS top_products
FROM `course15.circle_stock_kpi`;

UPDATE `course15.circle_stock_kpi_top` AS i
SET top_products = 1
FROM `course15.top_products` AS d
WHERE i.product_id = d.product_id;

-- 91-day average sales (up to Oct 1, 2021)
SELECT
  product_id,
  SUM(qty) AS qty_91,
  ROUND(SUM(qty) / 91) AS avg_daily_qty_91
FROM `course15.circle_sales`
WHERE date_date BETWEEN DATE('2021-07-02') AND DATE('2021-10-01')
GROUP BY product_id;

-- Watchlist: top products with low stock
SELECT
  product_id,
  stock,
  top_products
FROM `course15.circle_stock_kpi_top`
WHERE stock < 50 AND top_products = 1
ORDER BY stock ASC;

-- Estimate days of stock remaining
SELECT
  s.product_id,
  s.product_name,
  s.model_id,
  s.model_name,
  s.model_type,
  s.forecast_stock,
  d.avg_daily_qty_91,
  CASE
    WHEN d.avg_daily_qty_91 > 0 THEN ROUND(s.forecast_stock / d.avg_daily_qty_91, 1)
    ELSE NULL
  END AS nb_days
FROM `course15.circle_stock_kpi_top` s
LEFT JOIN `course15.circle_sales_daily` d
  ON s.product_id = d.product_id;

-- Prioritized stock monitoring query as low-stock watchlist ⭐

SELECT
  -- Identity
  s.product_id,
  s.product_name,
  s.model_id,
  s.model_name,
  s.model_type,
  s.color,
  s.color_name,
  s.size,

  -- Inventory
  s.stock,
  s.forecast_stock,
  s.in_stock,

  -- Business value
  s.price,
  s.stock_value,

  -- Demand signal
  s.top_products,
  d.qty_91,
  d.avg_daily_qty_91,

  -- Replenishment urgency
  CASE
    WHEN d.avg_daily_qty_91 > 0 
         THEN ROUND(s.forecast_stock / d.avg_daily_qty_91, 1)
    ELSE NULL
  END AS nb_days_remaining,

  -- 🚨 Alert flag
  CASE
    WHEN s.forecast_stock < 50 AND s.top_products = 1 
         THEN "⚠️ Reorder soon"
    WHEN s.forecast_stock < 50 
         THEN "Low stock"
    ELSE "OK"
  END AS stock_status

FROM `course15.circle_stock_kpi_top` s
LEFT JOIN `course15.circle_sales_daily` d
  ON s.product_id = d.product_id
ORDER BY stock_status DESC, nb_days_remaining ASC;
