-- Challenge 01: Circle Inventory Management
-- Notes + queries

-------------------------------
-- 1) Data Exploration
-------------------------------

-- Circle stock: 9 columns, 468 rows
SELECT * FROM `course15.circle_stock` LIMIT 1000;

-- Check for NULL model_id
SELECT DISTINCT model_id
FROM `course15.circle_stock`
WHERE model_id IS NULL;

-- Row counts vs unique IDs
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT model_id) AS unique_ids
FROM `course15.circle_stock`;

-- Duplicates by model_id
SELECT model_id, COUNT(*) AS count
FROM `course15.circle_stock`
GROUP BY model_id
HAVING COUNT(*) >= 2;

-- Circle sales: 3 cols, ~20k rows
SELECT * FROM `course15.circle_sales` LIMIT 1000;

-- Confirm product_id uniqueness
SELECT product_id, COUNT(*) AS count
FROM `course15.circle_sales`
GROUP BY product_id
HAVING COUNT(*) >= 2;

-- Inspect duplicates for a specific model
SELECT model_id, color, size
FROM `course15.circle_stock`
WHERE model_id = "BR001AR01-JL02-W"
ORDER BY color, size;

-------------------------------
-- 2) Table Cleaning
-------------------------------

-- Build product_id
SELECT
  CONCAT(model_id, "-", color, "-", IFNULL(size, 'no-size')) AS product_id,
  *
FROM `course15.circle_stock`;

-- Confirm product_id uniqueness
SELECT
  CONCAT(model_id, "-", color, "-", IFNULL(size, 'no-size')) AS product_id,
  COUNT(*) AS count
FROM `course15.circle_stock`
GROUP BY product_id
HAVING COUNT(*) > 1;

-------------------------------
-- 3) Enrichment
-------------------------------

-- Add product_name
SELECT
  product_id,
  CONCAT(model_name, " ", color_name, " - Size ", IFNULL(size, '')) AS product_name,
  *
FROM `course15.circle_stock`;

-- Add model_type
SELECT
  product_id,
  product_name,
  CASE
    WHEN REGEXP_CONTAINS(LOWER(product_name), "tour de cou")
      OR REGEXP_CONTAINS(LOWER(product_name), "tapis")
      OR REGEXP_CONTAINS(LOWER(product_name), "gourde") THEN "Accessories"
    WHEN REGEXP_CONTAINS(LOWER(product_name), "t-shirt") THEN "T-shirt"
    WHEN REGEXP_CONTAINS(LOWER(REPLACE(product_name, "è", "e")), "brassiere")
      OR REGEXP_CONTAINS(LOWER(product_name), "crop-top") THEN "Crop-top"
    WHEN REGEXP_CONTAINS(LOWER(product_name), "legging") THEN "Legging"
    WHEN REGEXP_CONTAINS(LOWER(product_name), "short") THEN "Short"
    WHEN REGEXP_CONTAINS(LOWER(product_name), "débardeur")
      OR REGEXP_CONTAINS(LOWER(product_name), "haut") THEN "Top"
  END AS model_type,
  *
FROM `course15.circle_stock_name`;

-- Add in_stock + stock_value
SELECT
  *,
  CASE WHEN stock = 0 THEN "0" ELSE "1" END AS in_stock,
  stock * price AS stock_value
FROM `course15.circle_stock_cat`;

-- The enriched circle_stock_kpi view can now be used to perform in-depth analysis
-- of stock statistics (stock, shortage, stock_value) by model_name, model_type,
-- product_name, size. (14 columns, 468 rows)

-------------------------------
-- 4) Advanced SQL Extension: Views
-------------------------------

-- Consolidated view (cc_stock)
-- Combines product_id + product_name → model_type → KPIs
CREATE OR REPLACE VIEW `course15.cc_stock` AS
SELECT
  product_id,
  product_name,
  model_id,
  model_name,
  model_type,
  color,
  color_name,
  size,
  current_stock_level,
  forecasted_stock_level,
  price,
  in_stock,
  stock_value
FROM `course15.circle_stock_kpi`;

-- Aggregated view by model_type (cc_stock_model_type)
CREATE OR REPLACE VIEW `course15.cc_stock_model_type` AS
SELECT
  model_type,
  COUNT(in_stock) AS nb_products,
  SUM(CAST(in_stock AS INT64)) AS nb_products_in_stock,
  ROUND(AVG(1 - CAST(in_stock AS FLOAT64)), 3) AS shortage_rate,
  SUM(CAST(stock_value AS FLOAT64)) AS total_stock_value
FROM `course15.circle_stock_kpi`
GROUP BY model_type
ORDER BY model_type;
