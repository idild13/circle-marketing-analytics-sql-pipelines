# Circle Analytics — SQL Challenge Suite 

A portfolio of SQL challenges completed during Le Wagon’s Data Analytics Bootcamp using BigQuery for **Circle**, a circular, eco-responsible sportswear brand. Each challenge focuses on a different analytics workflow: **inventory**, **aggregation & pivots**, **parcel logistics**, and **sales funnel**. The work emphasizes **views vs. tables**, pipeline design, and performance trade-offs.

> Note: **Challenges are independent.** Skipping Challenge 3 (Parcel Tracking) does **not** affect Challenges 1–2 (Inventory) or Challenge 4 (Funnel).

---

## 📂 Repository Structure

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

Each challenge folder contains the **exact SQL** used in `sql-queries/` and a short local README with run notes. This top-level README summarizes objectives and artifacts across the suite.

---

## 🧰 Stack & Conventions

- **Warehouse**: Google BigQuery  
- **Source**: Google Sheets (linked to BigQuery)  
- **Schema names**: `course15.*`  
- **Views** end with `_view`; **tables** have no suffix.  
- **Hybrid strategy**: Use **views** for frequently refreshed, small datasets; **tables** to materialize aggregated, heavy computations.

---

## ✅ Challenge 01 — Data Request: Circle Inventory Management

**Goal:** Turn raw stock into enriched KPIs and compare **views vs. tables** for freshness and cost.

**Source tables**
- `circle_stock` (linked sheet)

**Transformations**
- `circle_stock_name_view` → add `product_id` & `product_name`
- `circle_stock_cat_view` → derive `model_type`
- `circle_stock_kpi_view` → compute `in_stock` & `stock_value`
- **Pipeline simplification**: one combined view `cc_stock`
- **Stakeholder view**: `cc_stock_model_type` aggregates KPIs by `model_type`

**Key metrics**
- Total products, shortage rate, total stock/value  
- KPIs refreshed hourly by relying on **views** (no manual table refresh)

**Deliverables**
- Views: `circle_stock_name_view`, `circle_stock_cat_view`, `circle_stock_kpi_view`, `cc_stock`, `cc_stock_model_type`
- (Optional) Tables when needed for snapshots (no `_view` suffix)

---

## 📊 Challenge 02 — Aggregation & SQL Pivot Table

**Goal:** KPI rollups, drilldowns, and pivots for inventory.

**Source tables**
- `circle_stock_kpi` (from Challenge 01 pipeline)

**Analyses**
- Global metrics:  
  - `COUNT(product_id)` (total products)  
  - `COUNTIF(in_stock="1")` (in stock)  
  - `COUNTIF(in_stock="0")/COUNT(*)` (shortage rate)  
  - `SUM(stock_value)`, `SUM(stock)`
- By `model_type` and by (`model_type`, `model_name`), sorted by `total_stock_value` (DESC)
- **Sales-linked enrichments** (top sellers & days of stock):  
  - Top products by `SUM(qty)` from `circle_sales`  
  - 91-day average sales & **days of stock** ≈ `forecast_stock / avg_daily_qty_91`

**Deliverables**
- Aggregation queries and result sets grouped by `model_type` and `model_name`
- “Top products” flagging & **low-stock watchlist** with days-remaining

---

## 📦 Challenge 03 — Parcel Tracking (SKIPPED)

> Skipped by design; documented here for completeness. Independent of other challenges.

**Goal:** Status, timing KPIs, and SLA-style analytics on parcels.

**Source tables**
- `cc_parcel`, `cc_parcel_product`

**Intended pipeline**
- **Status** via `CASE`: `Cancelled`, `In progress`, `In Transit`, `Delivered`
- **Date normalization** with `PARSE_DATE()` if needed  
- KPIs with `DATE_DIFF()`:  
  - `shipping_time` (purchase → shipping)  
  - `delivery_time` (shipping → delivery)  
  - `total_time` (purchase → delivery)
- **Aggregations**:  
  - Global stats → `cc_parcel_kpi_global`  
  - By carrier → `cc_parcel_kpi_transporter`  
  - By priority → `cc_parcel_kpi_priority` (+ `SAFE_DIVIDE(shipping_time,total_time)` ratio)  
  - Monthly trend → `cc_parcel_kpi_month` (via `EXTRACT(MONTH FROM date_purchase)`)
- **Delay analysis:** flag `delay` where `total_time > 5` days and compute `delay_rate`

**Deliverables (stubs)**
- View/table names and schema contracts for future implementation

---

## 🧲 Challenge 04 — Acquisition Funnel

**Goal:** Build a complete **Lead → Opportunity → Customer** funnel with conversion rates & cycle times.

**Source table**
- `cc_funnel` (linked sheet)

**Transformations**
- `cc_funnel_kpi` with `deal_stage`:
  - `Lead` if no later dates
  - `Opportunity` if `date_opportunity` present and no `date_customer`/`date_lost`
  - `Customer` if `date_customer` present
  - `Churn` if `date_lost` present

**Analyses**
- Current funnel state: global counts, by `priority`, and pivot with stages as columns
- Conversion metrics & times:
  - Booleans: `Lead2Opportunity`, `Opportunity2Customer`, `Lead2Customers`
  - Times: `DATE_DIFF` between **stage dates** (L2O, O2C, L2C)
  - Aggregations: global, by `priority`, by month (`EXTRACT(MONTH FROM date_lead)`)

**Deliverables**
- `cc_funnel_kpi` plus aggregated result queries for counts, rates, and average times

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

## 🧩 What I Focused On

- **Pipelines that scale**: layered views, then selective materialization
- **Naming clarity**: `_view` vs. table, consistent object prefixes (`cc_*`)
- **Business-ready outputs**: stakeholder-specific views (e.g., `cc_stock_model_type`)
- **Performance awareness**: read volume & compute time trade-offs

---

## 🔭 Roadmap

- Scheduled refresh (BigQuery Scheduled Queries, dbt, or Airflow)  
- Data quality checks for dates and referential integrity  
- Alerts for shortage & delayed parcels  
- Visualization (Looker Studio/Hex/Metabase) on top of the views

---

## 📚 Source & Challenge Briefs

Bootcamp handouts and solution references for the four challenges (inventory, aggregation/pivot, parcels, funnel).  [oai_citation:0‡Challenges - July 14.pdf](file-service://file-1nQbciSAy9VCS836zJY7f9)
