
# Dashboard Charts Guide
## Prescription Analytics Dashboard - Visual Reference

---

## Chart Catalog Overview

| Chart # | Chart Name | Type | KPIs Displayed | Section |
|---------|-----------|------|----------------|---------|
| 1 | Total Expenditure | Big Number | Total Cost | Executive |
| 2 | Cost Per Claim | Big Number | CPC | Executive |
| 3 | Generic Rate | Big Number | GDR | Executive |
| 4 | Cost Per Member | Big Number | PMPM | Executive |
| 5 | Top 25 High-Cost Drugs | Bar Chart | Drug Cost Analysis | Cost Intelligence |
| 6 | Specialty Risk Matrix | Bubble Chart | Risk Segmentation | Cost Intelligence |
| 7 | Brand vs Generic Flow | Sankey Diagram | Cost Distribution | Cost Intelligence |
| 8 | City Cost Heatmap | Treemap | Geographic Analysis | Network |
| 9 | Prescriber Efficiency Table | Table | Provider Profiling | Network |
| 10 | Prescriber Scatter Plot | Scatter | Efficiency Analysis | Network |
| 11 | Days Supply Distribution | Histogram | Adherence Patterns | Clinical |
| 12 | Senior Cost Impact | Mixed Chart | Demographic Analysis | Clinical |
| 13 | Pareto Analysis | Bar + Line | 80/20 Rule | Risk |
| 14 | Outlier Detection | Bullet Chart | Risk Flagging | Risk |
| 15 | Risk Gauge Panel | Gauge (5x) | KRI Status | Risk |

---

## Section 1: Executive Overview

### Chart 1: Total Pharmaceutical Expenditure
**Chart Type:** Big Number 
**Visual Purpose:** At-a-glance total spend monitoring  
**Business Question:** What is our total pharmaceutical investment?

**KPI Displayed:**
- **Name:** Total Healthcare Expenditure
- **Formula:** `SUM(Tot_Drug_Cst)`
- **Purpose:** Baseline spend tracking, budget variance monitoring

**Chart Configuration:**
- Metric: Total drug cost
- Number Format: Currency ($XXX,XXX,XXX)


---

### Chart 2: Cost Per Claim Efficiency
**Chart Type:** Big Number 
**Visual Purpose:** Efficiency benchmark monitoring  
**Business Question:** Are we managing cost per transaction effectively?

**KPI Displayed:**
- **Name:** Cost Per Claim (CPC)
- **Formula:** `SUM(Tot_Drug_Cst) / SUM(Tot_Clms)`
- **Purpose:** Operational efficiency metric, specialty drug penetration indicator

**Chart Configuration:**
- Metric: Average cost per claim
- Number Format: Currency ($XXX.XX)




---

### Chart 3: Generic Dispensing Rate
**Chart Type:** Big Number
**Visual Purpose:** Clinical quality indicator  
**Business Question:** What percentage of prescriptions are generic?

**KPI Displayed:**
- **Name:** Generic Dispensing Rate (GDR)
- **Formula:** `COUNT(Generic Rx) / COUNT(Total Rx) × 100`
- **Purpose:** Quality measure, cost optimization indicator

**Chart Configuration:**
- Metric: Generic percentage
- Number Format: Percentage (XX.X%)


---

### Chart 4: Cost Per Member Per Month
**Chart Type:** Big Number  
**Visual Purpose:** Member-level cost tracking  
**Business Question:** What is the average monthly cost per beneficiary?

**KPI Displayed:**
- **Name:** PMPM (Per Member Per Month)
- **Formula:** `SUM(Tot_Drug_Cst) / SUM(Tot_Benes) / 12`
- **Purpose:** Member cost efficiency, plan bid calculation input

**Chart Configuration:**
- Metric: Monthly cost per member
- Number Format: Currency ($XXX)


---

## Section 2: Cost Intelligence

### Chart 5: Top 25 High-Cost Drugs
**Chart Type:** Horizontal Bar Chart 
**Visual Purpose:** Identify formulary optimization targets  
**Business Question:** Which drugs drive the highest total spend?

**KPIs Displayed:**
- **Primary:** Total Drug Cost (bar height)
- **Secondary:** Claim Volume (bar color intensity)
- **Tertiary:** Cost Per Claim (calculated metric)

**Chart Configuration:**
- X-Axis: Total cost (currency)
- Y-Axis: Brand name (sorted descending by cost)
- Data Labels: Show cost values
- Limit: Top 25 drugs


---

### Chart 6: Specialty Drug Risk Matrix
**Chart Type:** Bubble Chart  
**Visual Purpose:** Segment drugs by volume, intensity, and impact  
**Business Question:** Where are our highest risk specialty drugs?

**KPIs Displayed:**
- **X-Axis:** Claim Volume (utilization)
- **Y-Axis:** Cost Per Claim (intensity)
- **Bubble Size:** Total Cost (financial impact)
- **Color:** Prescriber Count (network exposure)

**Chart Configuration:**
- Interactive tooltips: Drug name, all metrics


---

### Chart 7: Brand vs Generic Cost Flow
**Chart Type:** Sankey Diagram  
**Visual Purpose:** Visualize cost distribution by drug type and tier  
**Business Question:** How does cost flow from drug type through tiers to specialties?

**KPIs Displayed:**
- **Flow Volume:** Total cost (thickness of bands)
- **Categories:** Drug Type → Cost Tier → Prescriber Specialty

**Chart Configuration:**
- Source Node: Brand vs Generic
- Middle Node: Specialty / Mid-Tier / Generic-Tier
- Target Node: Prescriber specialty


---

## Section 3: Network Intelligence

### Chart 8: City-Level Cost Treemap
**Chart Type:** Treemap  
**Visual Purpose:** Geographic cost concentration  
**Business Question:** Which cities have highest spend and cost variation?

**KPIs Displayed:**
- **Box Size:** Total Cost (larger = higher spend)
- **Box Color:** Cost Per Claim (gradient: green=low, red=high)
- **Label:** City name + total cost

**Chart Configuration:**
- Dimension: Prescriber city
- Size Metric: Total cost


---

### Chart 9: Prescriber Profiling Table
**Chart Type:** Table with Conditional Formatting  
**Visual Purpose:** Detailed provider performance metrics  
**Business Question:** Which prescribers require intervention or recognition?

**KPIs Displayed:**
- Prescriber Name, NPI, Specialty, City
- Total Claims, Total Cost
- Unique Drugs, Patients Served

**Chart Configuration:**
- Sort: Total cost (descending)
- Conditional Formatting:
  - Z-Score: Red (>2.5), Yellow (1.5-2.5), Green (<1.5)
  - CPC: Heatmap gradient
- Page Size: 50 rows


---

### Chart 10: Prescriber Efficiency Scatter
**Chart Type:** Scatter Plot  
**Visual Purpose:** Identify efficiency vs. quality trade-offs  
**Business Question:** Which prescribers balance cost and quality?

**KPIs Displayed:**
- **X-Axis:** Generic Dispensing Rate (quality)
- **Y-Axis:** Cost Per Claim (efficiency)
- **Point Size:** Total claim volume
- **Color:** Prescriber specialty




---

## Section 4: Clinical Quality

### Chart 11: Days Supply Distribution
**Chart Type:** Histogram  
**Visual Purpose:** Medication adherence patterns  
**Business Question:** What is the distribution of prescription lengths?

**KPI Displayed:**
- **Name:** Average Days Supply Per Claim
- **Formula:** `SUM(Tot_Day_Suply) / SUM(Tot_Clms)`
- **Purpose:** Adherence pattern analysis, 90-day fill program ROI

**Chart Configuration:**
- X-Axis: Days supply buckets (10-day intervals)
- Y-Axis: Prescription count
- Bins: 20 bins from 0-200 days


---

### Chart 12: Senior Population Cost Impact
**Chart Type:** Mixed Chart (Stacked Bar + Line)  
**Visual Purpose:** Demographic cost breakdown  
**Business Question:** How does 65+ population drive costs by specialty?

**KPIs Displayed:**
- **Bar (Stacked):** Senior Cost vs. Non-Senior Cost
- **Line (Secondary Axis):** Senior Cost Percentage

**Chart Configuration:**
- X-Axis: Prescriber specialty
- Y-Axis (Left): Total cost (currency)
- Y-Axis (Right): Percentage (0-100%)
