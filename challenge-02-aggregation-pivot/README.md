# Challenge 02 — Aggregation & SQL Pivot Table

This challenge builds on the cleaned `circle_stock_kpi` dataset from Challenge 01.  
The goal is to provide aggregated KPIs for the purchasing team and to estimate days of stock remaining for top-selling products.

---

## 📥 Source Data

- `circle_stock_kpi` (from Challenge 01 pipeline)  
- `circle_sales` (daily sales, linked from Google Sheets)  

---

## 📝 Run Notes

### 1) Stock Aggregation
- Calculated global KPIs:  
  - Total products  
  - Total in stock  
  - Shortage rate  
  - Total stock value  
  - Total stock  
- Aggregated by `model_type`, and then by (`model_type`, `model_name`) with results sorted by stock value.

### 2) Sales Aggregation
- Identified top 10 products sold (by quantity) from `circle_sales`.  
- Created `circle_stock_kpi_top` with a `top_products` flag.  
- Built `circle_sales_daily` to calculate:  
  - `qty_91` (last 91-day sales)  
  - `avg_daily_qty_91`  
- Estimated **days of stock remaining** by comparing `forecast_stock` to `avg_daily_qty_91`.

---

## 🎯 Result
- Clear KPI summaries for stock at global, type, and product levels.  
- Watchlist of **top-selling products with low stock** (<50 units).  
- Days of stock remaining metric to guide purchasing team on replenishment priorities.
