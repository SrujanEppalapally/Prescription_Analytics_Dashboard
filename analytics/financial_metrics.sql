-- ============================================================================
-- FINANCIAL METRICS - KPI SQL LIBRARY
-- Prescription Analytics Dashboard
-- ============================================================================
-- Purpose: Reusable SQL queries for all financial performance indicators
-- Dataset: Medicare Part D Prescriptions (New Jersey)
-- Category: Cost, Efficiency, and Spend Analytics
-- ============================================================================

-- =============================================================================
-- PRIMARY FINANCIAL KPIs
-- =============================================================================

-- KPI 1: Total Pharmaceutical Expenditure
-- Description: Aggregate drug spend across all analyzed claims
-- Usage: Big Number chart, executive dashboard
SELECT 
    SUM(Tot_Drug_Cst) as total_expenditure,
    'Total Healthcare Spend' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ';


-- KPI 2: Cost Per Claim (CPC)
-- Description: Average cost per individual prescription claim
-- Usage: Big Number with trendline, efficiency monitoring
SELECT 
    ROUND(SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0), 2) as cost_per_claim,
    'Cost Per Claim' as metric_name,
    CASE 
        WHEN SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0) > 150 THEN 'Red - High Risk'
        WHEN SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0) > 120 THEN 'Yellow - Monitor'
        ELSE 'Green - On Target'
    END as status
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ';


-- KPI 3: Cost Per Member Per Month (PMPM)
-- Description: Average monthly drug cost per unique beneficiary
-- Usage: Big Number chart, trend analysis
SELECT 
    ROUND(SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Benes), 0) / 12, 2) as pmpm,
    'Cost Per Member Per Month' as metric_name,
    CASE 
        WHEN SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Benes), 0) / 12 > 250 THEN 'Red - High Risk'
        WHEN SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Benes), 0) / 12 > 200 THEN 'Yellow - Monitor'
        ELSE 'Green - On Target'
    END as status
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ';


-- KPI 4: Total Claims Volume
-- Description: Total prescription transactions (activity metric)
-- Usage: Big Number chart, volume trend analysis
SELECT 
    SUM(Tot_Clms) as total_claims,
    COUNT(DISTINCT Prscrbr_NPI) as active_prescribers,
    SUM(Tot_Benes) as total_beneficiaries,
    'Claims Volume' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ';


-- =============================================================================
-- COST SEGMENTATION METRICS
-- =============================================================================

-- KPI 5: Brand Drug Cost Exposure
-- Description: Percentage of total spend on brand-name drugs
-- Usage: Pie chart, cost distribution analysis
SELECT 
    SUM(CASE WHEN LOWER(TRIM(Brnd_Name)) != LOWER(TRIM(Gnrc_Name)) THEN Tot_Drug_Cst ELSE 0 END) as brand_cost,
    SUM(CASE WHEN LOWER(TRIM(Brnd_Name)) = LOWER(TRIM(Gnrc_Name)) THEN Tot_Drug_Cst ELSE 0 END) as generic_cost,
    ROUND(SUM(CASE WHEN LOWER(TRIM(Brnd_Name)) != LOWER(TRIM(Gnrc_Name)) THEN Tot_Drug_Cst ELSE 0 END) * 100.0 / NULLIF(SUM(Tot_Drug_Cst), 0), 2) as brand_cost_pct,
    'Brand Drug Exposure' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ';


-- KPI 6: Specialty Drug Penetration Rate
-- Description: Percentage of total spend on specialty drugs (>$600/claim)
-- Usage: Gauge chart, cost risk monitoring
SELECT 
    SUM(CASE WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) > 600 THEN Tot_Drug_Cst ELSE 0 END) as specialty_cost,
    SUM(Tot_Drug_Cst) as total_cost,
    ROUND(SUM(CASE WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) > 600 THEN Tot_Drug_Cst ELSE 0 END) * 100.0 / NULLIF(SUM(Tot_Drug_Cst), 0), 2) as specialty_penetration_pct,
    'Specialty Drug Penetration' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ';


-- =============================================================================
-- COST EFFICIENCY METRICS
-- =============================================================================

-- KPI 7: Generic Savings Opportunity
-- Description: Potential savings from brand-to-generic substitution
-- Usage: Financial impact analysis, ROI calculator
SELECT 
    SUM(CASE WHEN LOWER(TRIM(Brnd_Name)) != LOWER(TRIM(Gnrc_Name)) THEN Tot_Drug_Cst ELSE 0 END) as current_brand_spend,
    ROUND(SUM(CASE WHEN LOWER(TRIM(Brnd_Name)) != LOWER(TRIM(Gnrc_Name)) THEN Tot_Drug_Cst ELSE 0 END) * 0.85, 0) as potential_savings_85pct,
    ROUND(SUM(CASE WHEN LOWER(TRIM(Brnd_Name)) != LOWER(TRIM(Gnrc_Name)) THEN Tot_Drug_Cst ELSE 0 END) * 0.50, 0) as conservative_savings_50pct,
    'Generic Substitution Opportunity' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ';


-- KPI 8: Cost Per Day Supply
-- Description: Cost efficiency normalized by days of therapy
-- Usage: Adherence program ROI analysis
SELECT 
    ROUND(SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Day_Suply), 0), 2) as cost_per_day_supply,
    ROUND(SUM(Tot_Day_Suply) / NULLIF(SUM(Tot_Drug_Cst), 0) * 100, 2) as days_per_hundred_dollars,
    'Cost Per Day Supply' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Day_Suply > 0;


-- =============================================================================
-- SENIOR POPULATION FINANCIAL METRICS
-- =============================================================================

-- KPI 9: Senior Population Drug Cost Ratio
-- Description: Percentage of total cost attributable to 65+ population
-- Usage: Demographic cost analysis, Medicare Part D alignment
SELECT 
    SUM(GE65_Tot_Drug_Cst) as senior_cost,
    SUM(Tot_Drug_Cst) - SUM(GE65_Tot_Drug_Cst) as non_senior_cost,
    ROUND(SUM(GE65_Tot_Drug_Cst) * 100.0 / NULLIF(SUM(Tot_Drug_Cst), 0), 2) as senior_cost_pct,
    SUM(GE65_Tot_Benes) as senior_patients,
    SUM(Tot_Benes) - SUM(GE65_Tot_Benes) as non_senior_patients,
    'Senior Population Cost Ratio' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND GE65_Sprsn_Flag != '*';  -- Exclude suppressed records


-- KPI 10: Senior PMPM
-- Description: Cost per member per month for 65+ population
-- Usage: Medicare Star Ratings, Part D bid calculations
SELECT 
    ROUND(SUM(GE65_Tot_Drug_Cst) / NULLIF(SUM(GE65_Tot_Benes), 0) / 12, 2) as senior_pmpm,
    ROUND((SUM(Tot_Drug_Cst) - SUM(GE65_Tot_Drug_Cst)) / NULLIF(SUM(Tot_Benes) - SUM(GE65_Tot_Benes), 0) / 12, 2) as non_senior_pmpm,
    'Senior vs Non-Senior PMPM' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND GE65_Sprsn_Flag != '*';


-- =============================================================================
-- COST DISTRIBUTION ANALYSIS
-- =============================================================================

-- KPI 11: Top Drugs by Cost (Pareto Analysis Input)
-- Description: Ranked drugs contributing to total spend
-- Usage: Identify formulary optimization targets
SELECT 
    Brnd_Name,
    Gnrc_Name,
    SUM(Tot_Drug_Cst) as drug_total_cost,
    SUM(Tot_Clms) as drug_claims,
    ROUND(SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0), 2) as drug_cost_per_claim,
    ROUND(SUM(Tot_Drug_Cst) * 100.0 / SUM(SUM(Tot_Drug_Cst)) OVER (), 2) as pct_of_total_cost,
    SUM(SUM(Tot_Drug_Cst)) OVER (ORDER BY SUM(Tot_Drug_Cst) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 100.0 / SUM(SUM(Tot_Drug_Cst)) OVER () as cumulative_cost_pct,
    ROW_NUMBER() OVER (ORDER BY SUM(Tot_Drug_Cst) DESC) as cost_rank
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Brnd_Name, Gnrc_Name
ORDER BY drug_total_cost DESC
LIMIT 100;


-- KPI 12: Cost by Prescriber Specialty
-- Description: Specialty-level cost aggregation
-- Usage: Network management, specialty-specific cost drivers
SELECT 
    Prscrbr_Type as specialty,
    COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
    SUM(Tot_Drug_Cst) as specialty_total_cost,
    SUM(Tot_Clms) as specialty_claims,
    ROUND(SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0), 2) as specialty_cost_per_claim,
    ROUND(SUM(Tot_Drug_Cst) * 100.0 / SUM(SUM(Tot_Drug_Cst)) OVER (), 2) as pct_of_total_cost
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Prscrbr_Type
HAVING COUNT(DISTINCT Prscrbr_NPI) >= 5  -- At least 5 prescribers
ORDER BY specialty_total_cost DESC;


-- KPI 13: Geographic Cost Concentration
-- Description: City-level cost aggregation
-- Usage: Network adequacy, regional cost variation analysis
SELECT 
    Prscrbr_City as city,
    COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
    SUM(Tot_Drug_Cst) as city_total_cost,
    SUM(Tot_Clms) as city_claims,
    ROUND(SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0), 2) as city_cost_per_claim,
    ROUND(SUM(Tot_Drug_Cst) * 100.0 / SUM(SUM(Tot_Drug_Cst)) OVER (), 2) as pct_of_total_cost
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Prscrbr_City
HAVING SUM(Tot_Clms) > 500  -- Minimum volume threshold
ORDER BY city_total_cost DESC
LIMIT 30;


-- =============================================================================
-- COST TREND & VARIANCE METRICS
-- =============================================================================

-- KPI 14: Cost Per Claim Distribution (Percentiles)
-- Description: Statistical distribution for benchmarking
-- Usage: Outlier detection thresholds, target setting
SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as p25_cost_per_claim,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as median_cost_per_claim,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as p75_cost_per_claim,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as p90_cost_per_claim,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as p95_cost_per_claim,
    AVG(Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as mean_cost_per_claim,
    STDDEV(Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as stddev_cost_per_claim,
    'Cost Per Claim Distribution' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Clms > 0;


-- KPI 15: High-Cost Drug Identification
-- Description: Drugs exceeding specialty threshold
-- Usage: Prior authorization candidates, formulary tier placement
SELECT 
    Brnd_Name,
    Gnrc_Name,
    SUM(Tot_Drug_Cst) as total_cost,
    SUM(Tot_Clms) as total_claims,
    ROUND(SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0), 2) as cost_per_claim,
    COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
    SUM(Tot_Benes) as affected_patients,
    CASE 
        WHEN SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0) > 1000 THEN 'Ultra High-Cost (>$1000)'
        WHEN SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0) > 600 THEN 'Specialty ($600-$1000)'
        WHEN SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0) > 200 THEN 'High-Cost ($200-$600)'
        ELSE 'Standard (<$200)'
    END as cost_tier
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Brnd_Name, Gnrc_Name
HAVING SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0) > 200  -- High-cost threshold
ORDER BY total_cost DESC;


-- =============================================================================
-- COMPOSITE FINANCIAL METRICS
-- =============================================================================

-- KPI 16: Financial Efficiency Index (Composite)
-- Description: Weighted composite of cost efficiency metrics
-- Formula: (1 - Specialty %) * 0.4 + (1 - Brand %) * 0.3 + (CPC Benchmark / Actual CPC) * 0.3
-- Usage: Executive scorecard, year-over-year comparison
WITH metrics AS (
    SELECT 
        SUM(CASE WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) > 600 THEN Tot_Drug_Cst ELSE 0 END) * 1.0 / NULLIF(SUM(Tot_Drug_Cst), 0) as specialty_rate,
        SUM(CASE WHEN LOWER(TRIM(Brnd_Name)) != LOWER(TRIM(Gnrc_Name)) THEN Tot_Drug_Cst ELSE 0 END) * 1.0 / NULLIF(SUM(Tot_Drug_Cst), 0) as brand_rate,
        SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0) as actual_cpc
    FROM medicare_prescriptions
    WHERE Prscrbr_State_Abrvtn = 'NJ'
)
SELECT 
    ROUND(((1 - specialty_rate) * 40 + (1 - brand_rate) * 30 + (100.0 / actual_cpc) * 30), 2) as financial_efficiency_index,
    ROUND(specialty_rate * 100, 2) as specialty_penetration_pct,
    ROUND(brand_rate * 100, 2) as brand_cost_pct,
    ROUND(actual_cpc, 2) as cost_per_claim,
    'Financial Efficiency Index' as metric_name
FROM metrics;


-- ============================================================================
-- END OF FINANCIAL METRICS
-- ============================================================================
