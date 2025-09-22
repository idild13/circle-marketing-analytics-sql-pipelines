# Circle Analytics — SQL Challenge Suite 

A portfolio of SQL challenges completed during Le Wagon’s Data Analytics Bootcamp using BigQuery for **Circle**, a circular, eco-responsible sportswear brand. Each challenge focuses on a different analytics workflow: **inventory**, **aggregation & pivots**, **parcel logistics**, and **sales funnel**. The work emphasizes **views vs. tables**, pipeline design, and performance trade-offs.

> Note: **Challenges are independent.** Skipping Challenge 3 (Parcel Tracking) does **not** affect Challenges 1–2 (Inventory) or Challenge 4 (Funnel).

---

## 📂 Repository Structure
```text
📁 circle-sql-challenges 
├─ 📁 challenge-01-inventory/                
│  ├─ 📁 sql-queries/
│  └─ 📄 README.md
├─ 📁 challenge-02-aggregation-pivot/       
│  ├─ 📁 sql-queries/
│  └─ 📄 README.md
├─ 📁 challenge-03-parcel-tracking/         
│  ├─ 📁 sql-queries/
│  └─ 📄 README.md
├─ 📁 challenge-04-acquisition-funnel/       
│  ├─ 📁 sql-queries/
│  └─ 📄 README.md
└─ 📄 README.md                               
```
Each challenge folder contains the **exact SQL** used in `sql-queries/` and a short local README with run notes. This top-level README summarizes objectives and artifacts across the suite.

---

## 🧰 Stack & Conventions

- **Warehouse**: Google BigQuery  
- **Source**: Google Sheets (linked to BigQuery)  
- **Schema names**: `course15.*`  
- **Views** end with `_view`; **tables** have no suffix.  
- **Hybrid strategy**: Use **views** for frequently refreshed, small datasets; **tables** to materialize aggregated, heavy computations.

---

## 📝 Challenge Details

### ✅ Challenge 01 — Data Request: Circle Inventory Management

**Goal:** Transform raw stock data into an enriched KPI dataset and compare **views vs. tables** for freshness and cost.

**Source tables**
- `circle_stock` (linked from Google Sheets)
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
- Views: `circle_stock_name_view`, `circle_stock_cat_view`, `circle_stock_kpi_view`, `cc_stock`, `cc_stock_model_type`  
- Optional tables for snapshots (no `_view` suffix)

---

### 📊 Challenge 02 — Aggregation & SQL Pivot Table

**Goal:** Roll up KPIs, build pivot-style summaries, and estimate days of stock for top sellers.

**Source**
- `circle_stock_kpi` (output of Challenge 01)

**Analyses**
- Global metrics: product count, in-stock %, shortage %, stock & value totals  
- Grouped by `model_type` and by (`model_type`, `model_name`)  
- Sales enrichment: top products via `SUM(qty)` in `circle_sales`  
- 91-day average sales & days-of-stock calculation (`forecast_stock / avg_daily_qty_91`)

**Deliverables**
- Aggregation queries and tables grouped by category & product  
- Watchlist of fast-moving items with low stock

---

### 📦 Challenge 03 — Parcel Tracking *(Skipped)*

Planned (but not implemented) analysis for the logistics team: shipment status, delivery times, delays, and refund rates.

**Data (for future use)**
- `cc_parcel`
- `cc_parcel_product`

**Intended outputs**
- `cc_parcel_kpi` with `status`, `shipping_time`, `delivery_time`, `total_time`  
- Aggregations by carrier, priority, and month  
- Delay metrics (`delay_rate`)

---

### 🧲 Challenge 04 — Acquisition Funnel

**Goal:** Build a complete **Lead → Opportunity → Customer** funnel with conversion rates and cycle times.

**Source table**
- `cc_funnel` (linked sheet)

**Transformations**
- `cc_funnel_kpi` with `deal_stage` (Lead, Opportunity, Customer, Lost)

**Analyses**
- Current funnel state (global, by priority, pivoted by stage)  
- Conversion rates (L2O, O2C, L2C)  
- Average times between stages (DATE_DIFF)  
- Monthly evolution (`EXTRACT(MONTH FROM date_lead)`)

**Deliverables**
- `cc_funnel_kpi` plus aggregated reports on counts, rates, and cycle lengths

---

## 🧪 Repro (BigQuery)

1) **Load sheets** → BigQuery:  
   - Inventory: `circle_stock`, `circle_sales`  
   - Parcels: `cc_parcel`, `cc_parcel_product`  
   - Funnel: `cc_funnel`  
   Use “Create table from Google Sheets”; set **Header rows to skip = 1**.

2) **Create views** in order (per challenge). Use `_view` suffix for reusable logic.

3) **Materialize** heavy/slow queries as **tables** where freshness isn’t critical (e.g., `cc_sales_daily`).

4) **Validate**:
   - Run inventory views; update the source sheet; confirm auto-refresh via views
   - Compare **performance**: `cc_sales_daily_view` vs `cc_stock` (rows read, slot time)
   - Inspect parcel KPIs & delay rates (if implementing Challenge 03 later)
   - Check funnel conversion rates & times by priority and month

---

## 🚀 Outcomes
- Built robust SQL pipelines for stock, sales, and funnel analytics.  
- Delivered datasets ready for BI dashboards and stakeholder reporting.  
- Practiced performance trade-offs (**views vs. tables**) and consistent naming.

---

## 📑 References
- Bootcamp briefs for all challenges
