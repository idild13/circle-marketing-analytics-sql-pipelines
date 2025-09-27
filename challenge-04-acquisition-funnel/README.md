# Challenge 04 — Acquisition Funnel

This challenge focuses on analyzing **Circle’s B2B acquisition funnel** to help the sales team monitor leads, opportunities, and customers.

The sales team’s goals are to:
- Generate leads and reach sales goals.  
- Prioritize high-value prospects.  
- Track funnel conversion rates and cycle times.  
- Measure pipeline efficiency.  

---

## 📥 Source Data

From **15 - Circle Funnel Google Sheet** → imported into `course15` dataset as:  
- `cc_funnel` → raw funnel data  

---

## 📚 Data Dictionary

**cc_funnel**  
- `company` – unique identifier of prospect  
- `sector` – industry  
- `date_lead` – when entered funnel  
- `date_opportunity` – when became an opportunity  
- `date_customer` – when converted to customer  
- `date_lost` – when marked as lost  
- `priority` – prospect importance  

---

## 📝 Run Notes

### 1) Data Exploration
- Inspected `cc_funnel` structure.  
- Verified `company` as primary key (fixed duplicates like “Crazy Running” directly in source).  

### 2) Data Enrichment
- Added **deal_stage** column: Lead / Opportunity / Customer / Churn.  
- Created conversion flags + times:  
  - `Lead2Opportunity`, `Lead2Opportunity_Time`  
  - `Lead2Customers`, `Lead2Customers_Time`  
  - `Opportunity2Customer`, `Opportunity2Customer_Time`  
- Saved as **`cc_funnel_kpi`** (main enriched table).  

### 3) Funnel State
- Global overview: number of prospects by stage.  
- By priority: grouped breakdown.  
- Pivot by priority with 4 stage columns.  

### 4) Funnel Statistics
- Conversion counts + rates (L2O, O2C, L2C).  
- Conversion times (average days between stages).  
- Aggregated at 3 levels:  
  - **Global**  
  - **By priority**  
  - **By month** (via `EXTRACT(MONTH FROM date_lead)`).  

---

## 📑 Deliverables

- **Tables**  
  - `cc_funnel` → raw import.  
  - `cc_funnel_kpi` → enriched with deal_stage + KPIs (grouped by deal_stage and priority).  

- **Analytical Outputs (queries only)**  
  - Funnel state: global, by priority, pivot.  
  - Conversion KPIs: counts, rates, times (global, by priority, by month).  

---

## 🎯 Result
The sales team now has a clear, query-ready view of the funnel:  
- Current pipeline state.  
- Conversion rates and bottlenecks.  
- Average cycle times per stage.  
- Insights broken down by prospect priority and by month.  
