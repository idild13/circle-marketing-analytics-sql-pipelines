# Challenge 02 — Aggregation & SQL Pivot Table

This challenge builds on the enriched `circle_stock_kpi` table from Challenge 1.  
It focuses on summarizing KPIs and analyzing **top-selling products** to help the purchasing team:  

- **Control stockouts** by monitoring shortage rates.  
- **Anticipate future sales** by linking stock with sales velocity.  
- **Prioritize reorders** for products with low forecast coverage.  

---

## 📥 Source Data

- The enriched `circle_stock_kpi` table from Challenge 1
- `circle_sales` table

---

## 📝 Run Notes

### 1) Stock Aggregation
- Calculated KPIs globally and by `model_type`:  
  - Total products  
  - Products in stock  
  - Shortage rate (`COUNTIF(in_stock=0)/COUNT(*)`)  
  - Total stock value (`SUM(stock_value)`)  
  - Total stock quantity (`SUM(stock)`)  
- Extended aggregation by (`model_type`, `model_name`) and sorted by stock value.  
- Outputs: insight into where shortages and value are concentrated.  

### 2) Sales Aggregation
- Identified **top 10 products** by total sales quantity → stored in `top_products`.  
- Flagged them in stock table via new column `top_products` → saved as `circle_stock_kpi_top`.  
- Aggregated 91-day sales window (July–Sept 2021):  
  - `qty_91` = total units sold in last 91 days  
  - `avg_daily_qty_91` = average daily sales  
  - Saved in `circle_sales_daily`.  
- Cross-joined with `circle_stock_kpi_top` to estimate `nb_days_remaining = forecast_stock / avg_daily_qty_91`.  

---

## 📊 Deliverables
- **Tables**:  
  - [circle_stock_kpi_top](https://docs.google.com/spreadsheets/d/19Tw8Q3HP5bCgRVrJ7VsR0OsAth86miYG8Ux3HhxS_z8/edit?usp=sharing) — enriched stock table with `top_products` flag.  
  - [circle_sales_daily](https://docs.google.com/spreadsheets/d/1Bi9BHxGPldT7FT_yOD9BOG1ufUTO529f2aJkVlOBNq0/edit?usp=sharing) — sales velocity metrics per product.  
- **Queries**:  
  - Aggregations at product, model, and type levels.  
  - **Prioritized stock monitoring query** with:  
    - Sales velocity (`avg_daily_qty_91`)  
    - Days of stock remaining (`nb_days_remaining`)  
    - Risk flag (`stock_status`: OK / Low stock / ⚠️ Reorder soon)  

---

## 🎯 Result
The purchasing team now has:  
- A global and segmented view of stock health.  
- Visibility into top sellers and their stock coverage.  
- A **low-stock watchlist** that highlights products at risk of running out soon.  
- A **decision-ready query** that prioritizes urgent reorders.  
