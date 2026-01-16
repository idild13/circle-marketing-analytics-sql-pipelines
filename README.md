# Circle Marketing Analytics — Automated SQL Pipelines

Automated SQL pipelines completed during Le Wagon’s Data Analytics Bootcamp using BigQuery for **Circle**, a circular, eco-responsible sportswear brand. Each section focuses on a different analytics workflow: **inventory**, **aggregation & pivots**, and **sales funnel**. The work emphasizes **views vs. tables**, pipeline design, and performance trade-offs.

---

## 📂 Repository Structure
```text
📁 circle-marketing-analytics-sql-pipelines 
├─ 📁 inventory/                
│  ├─ 📁 sql-queries/
│  └─ 📄 README.md
├─ 📁 aggregation-pivot/
│  ├─ 📁 Screenshots/     
│  ├─ 📁 sql-queries/
│  └─ 📄 README.md
├─ 📁 acquisition-funnel/
│  ├─ 📁 Screenshots/         
│  ├─ 📁 sql-queries/
│  └─ 📄 README.md
└─ 📄 README.md                               
```
Each folder contains the **exact SQL** used in `sql-queries/` and a short local README with run notes. This top-level README summarizes objectives and artifacts across the pipeline.

---

## 🧰 Stack & Conventions

- **Warehouse**: Google BigQuery  
- **Source**: Google Sheets (linked to BigQuery)  
- **Schema names**: `course15.*`  
- **Views** end with `_view`; **tables** have no suffix.  
- **Hybrid strategy**: Use **views** for frequently refreshed, small datasets; **tables** to materialize aggregated, heavy computations.

---

## 📝 Project Details

### ✅ Data Request: Circle Inventory Management

**Goal:** Transform raw stock data into an enriched KPI dataset and compare **views vs. tables** for freshness and cost.

**Source tables**
- `circle_stock` (Google Sheets  → BigQuery)
- `circle_sales`

**Transformations**
- `circle_stock_name_view` → add `product_id` & `product_name`
- `circle_stock_cat_view` → derive `model_type`
- `circle_stock_kpi_view` → compute `in_stock` & `stock_value`
- Combine into `cc_stock` for a simplified pipeline
- `cc_stock_model_type` → aggregates KPIs by `model_type`

**Key metrics**
- Total products, shortage rate, stock quantity, stock value  
- KPIs refresh automatically via **views**

**Deliverables**
- Views: circle_stock_name_view, circle_stock_cat_view, circle_stock_kpi_view, cc_stock, cc_stock_model_type
- Optional tables for snapshots (no _view suffix) 

**Advanced SQL Extension**

Later, the pipeline was restructured to replace intermediate tables with views, keeping the data always fresh. Consolidation into cc_stock and cc_stock_model_type reduced complexity while maintaining stakeholder-ready KPIs.

---

### 📊 Aggregation & SQL Pivot Table

**Goal:** Roll up KPIs, build pivot-style summaries, and estimate days of stock for top sellers.

**Source**
- `circle_stock_kpi` (output of Data Request: Circle Inventory Management)

**Analyses**
- **Global metrics**: product counts, shortage rate, total stock & stock value  
- **Breakdowns**: by `model_type` and (`model_type`, `model_name`), sorted by total stock value  
- **Sales-linked enrichments**:  
  - Top 10 products (`SUM(qty)`) from `circle_sales`  
  - Rolling 91-day sales averages (`qty_91`, `avg_daily_qty_91`)  
  - Days of stock ≈ `forecast_stock / avg_daily_qty_91`  

**Deliverables**
- **Tables**:  
  - `circle_stock_kpi_top` → enriched with a `top_products` flag  
  - `circle_sales_daily` → 91-day sales aggregates  

- **Analytical outputs**  
  - Aggregated KPIs by type and model  
  - Low-stock watchlist with days-remaining until stockout  

**Advanced SQL Extension**
Introduced `cc_sales_daily_view` to practice the **view vs. table trade-off**:  
- Views provide *fresh, always up-to-date metrics*.  
- Tables save on *cost and runtime* for heavy queries on larger datasets.  

This reinforced the **hybrid pipeline strategy**.

---

### 🧲 Acquisition Funnel

**Goal:** Build a complete **Lead → Opportunity → Customer** funnel with conversion rates and cycle times to support the sales team.

**Source**
- `cc_funnel` (Google Sheet → BigQuery)

**Analyses**
- **Funnel state**
  - Global overview
  - By priority
  - Pivoted by priority × deal stage
- **Conversion statistics**
  - Lead → Opportunity (L2O)
  - Opportunity → Customer (O2C)
  - Lead → Customer (L2C)
- **Cycle times**
  - Average days between lead, opportunity, and customer stages
- **Breakdowns**
  - Global  
  - By priority  
  - By month  

**Deliverables**
- `cc_funnel_kpi` → enriched funnel table with `deal_stage` and conversion KPIs  
- Aggregated reports:
  - Funnel counts by stage
  - Conversion rates (L2O, O2C, L2C)
  - Average cycle lengths  

**Result**
- The sales team can monitor funnel health, conversion efficiency, and cycle length.  
- Enables prioritization of leads by urgency and better forecasting of pipeline performance.

---

## 🧪 Repro (BigQuery)

1) **Load sheets** → BigQuery:  
   - Inventory: `circle_stock`, `circle_sales`  
   - Parcels: `cc_parcel`, `cc_parcel_product`  
   - Funnel: `cc_funnel`  

2) **Create views** in order (per section). Use `_view` suffix for reusable logic.

3) **Materialize** heavy/slow queries as **tables** where freshness isn’t critical (e.g., `cc_sales_daily`).

4) **Validate**:
   - Run inventory views; update the source sheet; confirm auto-refresh via views
   - Compare **performance**: `cc_sales_daily_view` vs `cc_stock` (rows read, slot time)
   - Check funnel conversion rates & times by priority and month

---

## 🚀 Outcomes
- Built robust SQL pipelines for stock, sales, and funnel analytics.  
- Delivered datasets ready for BI dashboards and stakeholder reporting.  
- Practiced performance trade-offs (**views vs. tables**) and consistent naming.

---

## 📑 References
- Bootcamp briefs for all challenges
