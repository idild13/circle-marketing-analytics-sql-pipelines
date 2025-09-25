# Challenge 01 — Circle Inventory Management

This challenge focuses on cleaning and enriching **Circle’s stock data** in BigQuery to help the purchasing team monitor shortages, anticipate sales, and place the right orders on time.

---

## 📥 Source Data

From **15 - Circle Google Sheet**:  
- [Stock sheet](https://docs.google.com/spreadsheets/d/19cDDybWRQrWkGpGJfL6Yp63zkHXEtQRn_SNXySUm6sI/edit#gid=0) → `circle_stock`  
- [Sales sheet](https://docs.google.com/spreadsheets/d/19cDDybWRQrWkGpGJfL6Yp63zkHXEtQRn_SNXySUm6sI/edit#gid=1009765988) → `circle_sales`  

Imported into `course15` dataset (EU location).

---

## 📚 Data Dictionary

**Stock table (`circle_stock`)**
- `model_id` – unique model identifier  
- `color` – color acronym  
- `size` – product size (XS–XXL)  
- `model_name` – product model name  
- `color_name` – color description  
- `new` – whether recently added to catalog  
- `price` – unit price (€)  
- `stock` – quantity available in warehouse  
- `forecast_stock` – stock + incoming deliveries  

**Sales table (`circle_sales`)**
- `date_date` – sale date  
- `product_id` – concatenation of model_id + color + size  
- `qty` – quantity sold  

---

## 📝 Run Notes

### 1) Data Exploration & Cleaning
- Counted rows & columns (`circle_stock`: 9 cols, 468 rows; `circle_sales`: 3 cols, ~20k rows).  
- Confirmed **primary keys**:  
  - `product_id` in `circle_sales` (no duplicates).  
  - In `circle_stock`, single `model_id` had duplicates → primary key defined as `model_id + color + size`.  
- Built a new `product_id` by concatenation, replacing null sizes with `"no-size"` (using `IFNULL`).  

### 2) Data Enrichment
- Added `product_name`: *model_name + color_name + size* (e.g. `Brassière Level Up Black – Size L`).  
- Classified `model_type` via `CASE WHEN` + `REGEXP_CONTAINS` (Accessories, T-shirt, Crop-top, Legging, Short, Top).  
- Created KPIs:  
  - `in_stock` (1 if stock > 0, else 0).  
  - `stock_value` (`stock * price`).  

### 3) Outputs
- `circle_stock_name` – adds product_id & product_name.  
- `circle_stock_cat` – adds model_type.  
- [circle_stock_kpi](https://docs.google.com/spreadsheets/d/1FgA39GmpsrwM7L_QHlWOG6sUZaa1BTOr9WVsrtVyFNw/edit?usp=sharing) – final enriched table with KPIs (`in_stock`, `stock_value`).  

---

## ⚡ Advanced SQL Extension — Views vs. Tables

Later, I revisited this challenge to practice **views** and simplify the pipeline.  

- Originally, the pipeline required **3 intermediate tables**:  
  `circle_stock_name` → `circle_stock_cat` → `circle_stock_kpi`  

- I refactored them into **3 consecutive views**:  
  `circle_stock_name_view` → `circle_stock_cat_view` → `circle_stock_kpi_view`  

- Then, I consolidated them into a **single combined view**:  
  - `cc_stock` → a one-stop enriched view with all descriptive fields and KPIs.  
  - `cc_stock_model_type` → aggregates stock KPIs by `model_type` (total products, in-stock, shortage rate, total stock value).  

This made the pipeline **lighter, more maintainable, and always up-to-date**, since views re-run queries on the latest Google Sheets data.

---

## 🎯 Result
A cleaned and enriched dataset that gives the purchasing team a clear picture of:  
- stock levels,  
- shortage status,  
- product categories,  
- and stock value.  

Ready for downstream analysis, pivoting (Challenge 02), and dashboards.
