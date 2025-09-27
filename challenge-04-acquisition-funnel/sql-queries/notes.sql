-- Challenge 04: Acquisition Funnel
-- Notes + queries

-------------------------------
-- A) Data Exploration
-------------------------------

-- Check primary key
SELECT company, COUNT(*) AS nb
FROM `course15.cc_funnel`
GROUP BY company
HAVING nb >= 2
ORDER BY nb DESC;
-- Duplicate found for "Crazy Running" → fixed in source.

-------------------------------
-- B) Data Enrichment
-------------------------------

-- Add deal_stage and conversion KPIs → save as cc_funnel_kpi
SELECT
  *,
  CASE
    WHEN date_opportunity IS NULL AND date_customer IS NULL AND date_lost IS NULL THEN 'Lead'
    WHEN date_opportunity IS NOT NULL AND date_customer IS NULL AND date_lost IS NULL THEN 'Opportunity'
    WHEN date_customer IS NOT NULL AND date_lost IS NULL THEN 'Customer'
    WHEN date_lost IS NOT NULL THEN 'Churn'
  END AS deal_stage,
  -- Conversion flags + times
  IF(date_lead IS NOT NULL AND date_customer IS NOT NULL, 1, 0) AS Lead2Customers,
  IF(date_lead IS NOT NULL AND date_customer IS NOT NULL, DATE_DIFF(date_customer, date_lead, DAY), NULL) AS Lead2Customers_Time,
  IF(date_lead IS NOT NULL AND date_opportunity IS NOT NULL, 1, 0) AS Lead2Opportunity,
  IF(date_lead IS NOT NULL AND date_opportunity IS NOT NULL, DATE_DIFF(date_opportunity, date_lead, DAY), NULL) AS Lead2Opportunity_Time,
  IF(date_customer IS NOT NULL AND date_opportunity IS NOT NULL, 1, 0) AS Opportunity2Customer,
  IF(date_customer IS NOT NULL AND date_opportunity IS NOT NULL, DATE_DIFF(date_customer, date_opportunity, DAY), NULL) AS Opportunity2Customer_Time
FROM `course15.cc_funnel`
WHERE company IS NOT NULL;
-- Saved as cc_funnel_kpi

-------------------------------
-- C) Funnel State
-------------------------------

-- Global
SELECT deal_stage, COUNT(*) AS nb_prospects
FROM `course15.cc_funnel_kpi`
GROUP BY deal_stage;

-- By priority
SELECT deal_stage, priority, COUNT(*) AS nb_prospects
FROM `course15.cc_funnel_kpi`
GROUP BY deal_stage, priority
ORDER BY deal_stage;

-- Pivot by priority
SELECT
  priority,
  COUNTIF(deal_stage = 'Lead') AS Lead,
  COUNTIF(deal_stage = 'Opportunity') AS Opportunity,
  COUNTIF(deal_stage = 'Customer') AS Customer,
  COUNTIF(deal_stage = 'Churn') AS Churn
FROM `course15.cc_funnel_kpi`
GROUP BY priority;

-------------------------------
-- D) Funnel Statistics
-------------------------------

-- Global
SELECT
  COUNT(*) AS prospects,
  COUNT(date_customer) AS customers,
  ROUND(AVG(Lead2Customers) * 100, 1) AS lead2customer_rate,
  ROUND(AVG(Lead2Opportunity) * 100, 1) AS lead2opportunity_rate,
  ROUND(AVG(Opportunity2Customer) * 100, 1) AS opportunity2customer_rate,
  ROUND(AVG(Lead2Customers_Time), 1) AS avg_lead2customer_days,
  ROUND(AVG(Lead2Opportunity_Time), 1) AS avg_lead2opportunity_days,
  ROUND(AVG(Opportunity2Customer_Time), 1) AS avg_opportunity2customer_days
FROM `course15.cc_funnel_kpi`;

-- By priority
SELECT
  priority,
  COUNT(*) AS prospects,
  COUNT(date_customer) AS customers,
  ROUND(AVG(Lead2Customers) * 100, 1) AS lead2customer_rate,
  ROUND(AVG(Lead2Opportunity) * 100, 1) AS lead2opportunity_rate,
  ROUND(AVG(Opportunity2Customer) * 100, 1) AS opportunity2customer_rate,
  ROUND(AVG(Lead2Customers_Time), 1) AS avg_lead2customer_days,
  ROUND(AVG(Lead2Opportunity_Time), 1) AS avg_lead2opportunity_days,
  ROUND(AVG(Opportunity2Customer_Time), 1) AS avg_opportunity2customer_days
FROM `course15.cc_funnel_kpi`
GROUP BY priority;

-- By month
SELECT
  EXTRACT(MONTH FROM date_lead) AS month_lead,
  COUNT(*) AS prospects,
  COUNT(date_customer) AS customers,
  ROUND(AVG(Lead2Customers) * 100, 1) AS lead2customer_rate,
  ROUND(AVG(Lead2Opportunity) * 100, 1) AS lead2opportunity_rate,
  ROUND(AVG(Opportunity2Customer) * 100, 1) AS opportunity2customer_rate,
  ROUND(AVG(Lead2Customers_Time), 1) AS avg_lead2customer_days,
  ROUND(AVG(Lead2Opportunity_Time), 1) AS avg_lead2opportunity_days,
  ROUND(AVG(Opportunity2Customer_Time), 1) AS avg_opportunity2customer_days
FROM `course15.cc_funnel_kpi`
GROUP BY month_lead
ORDER BY month_lead;
