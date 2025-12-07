-- ============================================================================
-- EXPLORATORY ANALYSIS QUERIES
-- Prescription Analytics Dashboard - Ad-hoc Investigation Queries
-- ============================================================================
-- Purpose: Sample queries for data exploration and hypothesis testing
-- Dataset: Medicare Part D Prescriptions (New Jersey)
-- Last Updated: 2025-12-07
-- ============================================================================

-- =============================================================================
-- 1. DATA OVERVIEW & QUALITY CHECKS
-- =============================================================================

-- Total record count and basic statistics
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT Prscrbr_NPI) as unique_prescribers,
    COUNT(DISTINCT Brnd_Name) as unique_brand_drugs,
    COUNT(DISTINCT Gnrc_Name) as unique_generic_drugs,
    COUNT(DISTINCT Prscrbr_City) as unique_cities,
    COUNT(DISTINCT Prscrbr_Type) as unique_specialties,
    SUM(Tot_Clms) as total_claims,
    SUM(Tot_Drug_Cst) as total_expenditure,
    SUM(Tot_Benes) as total_beneficiaries
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ';

-- Data completeness check
SELECT 
    'Prscrbr_NPI' as field,
    COUNT(*) as total_records,
    COUNT(Prscrbr_NPI) as non_null_count,
    COUNT(*) - COUNT(Prscrbr_NPI) as null_count,
    ROUND(COUNT(Prscrbr_NPI) * 100.0 / COUNT(*), 2) as completeness_pct
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
UNION ALL
SELECT 
    'Tot_Drug_Cst',
    COUNT(*),
    COUNT(Tot_Drug_Cst),
    COUNT(*) - COUNT(Tot_Drug_Cst),
    ROUND(COUNT(Tot_Drug_Cst) * 100.0 / COUNT(*), 2)
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
UNION ALL
SELECT 
    'Tot_Benes',
    COUNT(*),
    COUNT(Tot_Benes),
    COUNT(*) - COUNT(Tot_Benes),
    ROUND(COUNT(Tot_Benes) * 100.0 / COUNT(*), 2)
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ';

-- CMS suppression flag analysis
SELECT 
    GE65_Sprsn_Flag,
    COUNT(*) as record_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as pct_of_total
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY GE65_Sprsn_Flag;


-- =============================================================================
-- 2. COST DISTRIBUTION ANALYSIS
-- =============================================================================

-- Cost per claim distribution (percentiles)
SELECT 
    PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as p10_cost_per_claim,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as p25_cost_per_claim,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as median_cost_per_claim,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as p75_cost_per_claim,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as p90_cost_per_claim,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as p95_cost_per_claim,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as p99_cost_per_claim
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Clms > 0;

-- Cost buckets (histogram data)
SELECT 
    CASE 
        WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) < 50 THEN '< $50'
        WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) < 100 THEN '$50-$100'
        WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) < 200 THEN '$100-$200'
        WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) < 500 THEN '$200-$500'
        WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) < 1000 THEN '$500-$1,000'
        ELSE '> $1,000'
    END as cost_bucket,
    COUNT(*) as record_count,
    SUM(Tot_Drug_Cst) as bucket_total_cost,
    ROUND(SUM(Tot_Drug_Cst) * 100.0 / SUM(SUM(Tot_Drug_Cst)) OVER (), 2) as pct_of_total_cost
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Clms > 0
GROUP BY 1
ORDER BY 
    CASE 
        WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) < 50 THEN 1
        WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) < 100 THEN 2
        WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) < 200 THEN 3
        WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) < 500 THEN 4
        WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) < 1000 THEN 5
        ELSE 6
    END;


-- =============================================================================
-- 3. DRUG ANALYSIS
-- =============================================================================

-- Top 50 drugs by total cost
SELECT 
    Brnd_Name,
    Gnrc_Name,
    SUM(Tot_Drug_Cst) as total_cost,
    SUM(Tot_Clms) as total_claims,
    COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
    SUM(Tot_Benes) as patient_count,
    ROUND(SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0), 2) as avg_cost_per_claim,
    ROUND(SUM(Tot_Drug_Cst) * 100.0 / SUM(SUM(Tot_Drug_Cst)) OVER (), 2) as pct_of_total_cost
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Brnd_Name, Gnrc_Name
ORDER BY total_cost DESC
LIMIT 50;

-- Brand vs Generic comparison
SELECT 
    CASE 
        WHEN LOWER(TRIM(Brnd_Name)) = LOWER(TRIM(Gnrc_Name)) THEN 'Generic'
        ELSE 'Brand'
    END as drug_type,
    COUNT(*) as record_count,
    SUM(Tot_Clms) as total_claims,
    SUM(Tot_Drug_Cst) as total_cost,
    ROUND(AVG(Tot_Drug_Cst / NULLIF(Tot_Clms, 0)), 2) as avg_cost_per_claim,
    SUM(Tot_Benes) as total_beneficiaries,
    ROUND(SUM(Tot_Drug_Cst) * 100.0 / SUM(SUM(Tot_Drug_Cst)) OVER (), 2) as pct_of_total_cost
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Clms > 0
GROUP BY 1;

-- Identify potential generic substitution opportunities
SELECT 
    Brnd_Name,
    Gnrc_Name,
    SUM(Tot_Drug_Cst) as brand_total_cost,
    SUM(Tot_Clms) as brand_claims,
    COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
    ROUND(SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0), 2) as brand_cost_per_claim,
    -- Estimated savings if 80% converted to generic (assuming 85% cost reduction)
    ROUND(SUM(Tot_Drug_Cst) * 0.80 * 0.85, 0) as estimated_savings
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND LOWER(TRIM(Brnd_Name)) != LOWER(TRIM(Gnrc_Name))  -- Brand drugs only
    AND Tot_Clms > 100  -- Significant volume
GROUP BY Brnd_Name, Gnrc_Name
HAVING SUM(Tot_Drug_Cst) > 100000  -- High cost drugs
ORDER BY estimated_savings DESC
LIMIT 25;


-- =============================================================================
-- 4. PRESCRIBER ANALYSIS
-- =============================================================================

-- Prescriber specialty distribution
SELECT 
    Prscrbr_Type as specialty,
    COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
    SUM(Tot_Clms) as total_claims,
    SUM(Tot_Drug_Cst) as total_cost,
    ROUND(AVG(Tot_Drug_Cst / NULLIF(Tot_Clms, 0)), 2) as avg_cost_per_claim,
    ROUND(SUM(Tot_Drug_Cst) * 100.0 / SUM(SUM(Tot_Drug_Cst)) OVER (), 2) as pct_of_total_cost
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Prscrbr_Type
HAVING COUNT(DISTINCT Prscrbr_NPI) >= 5  -- At least 5 prescribers
ORDER BY total_cost DESC;

-- High-volume prescribers
SELECT 
    Prscrbr_NPI,
    Prscrbr_Last_Org_Name,
    Prscrbr_Type,
    Prscrbr_City,
    SUM(Tot_Clms) as total_claims,
    SUM(Tot_Drug_Cst) as total_cost,
    COUNT(DISTINCT Brnd_Name) as unique_drugs_prescribed,
    SUM(Tot_Benes) as patients_served,
    ROUND(SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0), 2) as avg_cost_per_claim,
    ROUND(SUM(Tot_Clms) * 1.0 / NULLIF(SUM(Tot_Benes), 0), 2) as claims_per_patient
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Prscrbr_NPI, Prscrbr_Last_Org_Name, Prscrbr_Type, Prscrbr_City
ORDER BY total_claims DESC
LIMIT 50;

-- Prescriber cost efficiency outliers (Z-score analysis)
WITH prescriber_metrics AS (
    SELECT 
        Prscrbr_NPI,
        Prscrbr_Last_Org_Name,
        Prscrbr_Type,
        SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0) as cost_per_claim,
        SUM(Tot_Clms) as total_claims,
        SUM(Tot_Drug_Cst) as total_cost
    FROM medicare_prescriptions
    WHERE Prscrbr_State_Abrvtn = 'NJ'
    GROUP BY Prscrbr_NPI, Prscrbr_Last_Org_Name, Prscrbr_Type
    HAVING SUM(Tot_Clms) > 100  -- Minimum volume threshold
),
stats AS (
    SELECT 
        AVG(cost_per_claim) as mean_cpc,
        STDDEV(cost_per_claim) as stddev_cpc
    FROM prescriber_metrics
)
SELECT 
    pm.Prscrbr_NPI,
    pm.Prscrbr_Last_Org_Name,
    pm.Prscrbr_Type,
    pm.total_claims,
    ROUND(pm.total_cost, 0) as total_cost,
    ROUND(pm.cost_per_claim, 2) as cost_per_claim,
    ROUND(s.mean_cpc, 2) as population_avg_cpc,
    ROUND((pm.cost_per_claim - s.mean_cpc) / NULLIF(s.stddev_cpc, 0), 2) as z_score,
    CASE 
        WHEN ABS((pm.cost_per_claim - s.mean_cpc) / NULLIF(s.stddev_cpc, 0)) > 3 THEN 'Critical Outlier'
        WHEN ABS((pm.cost_per_claim - s.mean_cpc) / NULLIF(s.stddev_cpc, 0)) > 2 THEN 'Moderate Outlier'
        WHEN ABS((pm.cost_per_claim - s.mean_cpc) / NULLIF(s.stddev_cpc, 0)) > 1.5 THEN 'Mild Outlier'
        ELSE 'Normal'
    END as outlier_status
FROM prescriber_metrics pm
CROSS JOIN stats s
WHERE ABS((pm.cost_per_claim - s.mean_cpc) / NULLIF(s.stddev_cpc, 0)) > 1.5
ORDER BY z_score DESC;


-- =============================================================================
-- 5. GEOGRAPHIC ANALYSIS
-- =============================================================================

-- City-level cost analysis
SELECT 
    Prscrbr_City,
    COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
    SUM(Tot_Clms) as total_claims,
    SUM(Tot_Drug_Cst) as total_cost,
    ROUND(AVG(Tot_Drug_Cst / NULLIF(Tot_Clms, 0)), 2) as avg_cost_per_claim,
    SUM(Tot_Benes) as beneficiary_count,
    ROUND(SUM(Tot_Drug_Cst) * 100.0 / SUM(SUM(Tot_Drug_Cst)) OVER (), 2) as pct_of_total_cost
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Prscrbr_City
HAVING SUM(Tot_Clms) > 500  -- Minimum volume threshold
ORDER BY total_cost DESC
LIMIT 30;


-- =============================================================================
-- 6. SENIOR POPULATION (65+) ANALYSIS
-- =============================================================================

-- Senior vs non-senior cost comparison by specialty
SELECT 
    Prscrbr_Type,
    SUM(GE65_Tot_Drug_Cst) as senior_cost,
    SUM(Tot_Drug_Cst) - SUM(GE65_Tot_Drug_Cst) as non_senior_cost,
    ROUND(SUM(GE65_Tot_Drug_Cst) * 100.0 / NULLIF(SUM(Tot_Drug_Cst), 0), 2) as senior_cost_pct,
    SUM(GE65_Tot_Benes) as senior_patients,
    SUM(Tot_Benes) - SUM(GE65_Tot_Benes) as non_senior_patients,
    ROUND(SUM(GE65_Tot_Drug_Cst) / NULLIF(SUM(GE65_Tot_Benes), 0), 2) as senior_cost_per_patient,
    ROUND((SUM(Tot_Drug_Cst) - SUM(GE65_Tot_Drug_Cst)) / NULLIF(SUM(Tot_Benes) - SUM(GE65_Tot_Benes), 0), 2) as non_senior_cost_per_patient
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND GE65_Sprsn_Flag != '*'  -- Exclude suppressed records
GROUP BY Prscrbr_Type
HAVING SUM(Tot_Drug_Cst) > 100000
ORDER BY senior_cost DESC;


-- =============================================================================
-- 7. ADHERENCE & UTILIZATION PATTERNS
-- =============================================================================

-- Days supply distribution analysis
SELECT 
    CASE 
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 20 THEN '< 20 days'
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 30 THEN '20-30 days'
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 60 THEN '30-60 days'
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 90 THEN '60-90 days'
        ELSE '90+ days'
    END as days_supply_bucket,
    COUNT(*) as record_count,
    SUM(Tot_Clms) as total_claims,
    SUM(Tot_Drug_Cst) as total_cost,
    ROUND(AVG(Tot_30day_Fills / NULLIF(Tot_Day_Suply / 30, 0)), 3) as avg_mpr_estimate
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Clms > 0
    AND Tot_Day_Suply > 0
GROUP BY 1
ORDER BY 
    CASE 
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 20 THEN 1
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 30 THEN 2
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 60 THEN 3
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 90 THEN 4
        ELSE 5
    END;

-- Claims per beneficiary by specialty
SELECT 
    Prscrbr_Type,
    COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
    SUM(Tot_Clms) as total_claims,
    SUM(Tot_Benes) as total_beneficiaries,
    ROUND(SUM(Tot_Clms) * 1.0 / NULLIF(SUM(Tot_Benes), 0), 2) as claims_per_beneficiary,
    ROUND(AVG(Tot_Day_Suply / NULLIF(Tot_Clms, 0)), 1) as avg_days_supply_per_claim
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Benes > 0
GROUP BY Prscrbr_Type
HAVING SUM(Tot_Benes) > 100
ORDER BY claims_per_beneficiary DESC;


-- =============================================================================
-- 8. POLYPHARMACY ANALYSIS
-- =============================================================================

-- Drugs per prescriber distribution
WITH drugs_per_prescriber AS (
    SELECT 
        Prscrbr_NPI,
        Prscrbr_Type,
        COUNT(DISTINCT Gnrc_Name) as unique_drugs,
        SUM(Tot_Benes) as total_patients
    FROM medicare_prescriptions
    WHERE Prscrbr_State_Abrvtn = 'NJ'
    GROUP BY Prscrbr_NPI, Prscrbr_Type
)
SELECT 
    CASE 
        WHEN unique_drugs < 5 THEN '< 5 drugs'
        WHEN unique_drugs < 10 THEN '5-10 drugs'
        WHEN unique_drugs < 20 THEN '10-20 drugs'
        WHEN unique_drugs < 50 THEN '20-50 drugs'
        ELSE '50+ drugs'
    END as drug_count_bucket,
    COUNT(*) as prescriber_count,
    ROUND(AVG(unique_drugs), 1) as avg_drugs_in_bucket,
    SUM(total_patients) as total_patients
FROM drugs_per_prescriber
GROUP BY 1
ORDER BY 
    CASE 
        WHEN unique_drugs < 5 THEN 1
        WHEN unique_drugs < 10 THEN 2
        WHEN unique_drugs < 20 THEN 3
        WHEN unique_drugs < 50 THEN 4
        ELSE 5
    END;


-- =============================================================================
-- 9. PARETO ANALYSIS (80/20 RULE)
-- =============================================================================

-- Drugs contributing to 80% of total cost
WITH drug_costs AS (
    SELECT 
        Brnd_Name,
        SUM(Tot_Drug_Cst) as drug_cost,
        SUM(SUM(Tot_Drug_Cst)) OVER (ORDER BY SUM(Tot_Drug_Cst) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total,
        SUM(SUM(Tot_Drug_Cst)) OVER () as grand_total
    FROM medicare_prescriptions
    WHERE Prscrbr_State_Abrvtn = 'NJ'
    GROUP BY Brnd_Name
)
SELECT 
    Brnd_Name,
    ROUND(drug_cost, 0) as drug_cost,
    ROUND(running_total * 100.0 / grand_total, 2) as cumulative_pct,
    ROW_NUMBER() OVER (ORDER BY drug_cost DESC) as drug_rank
FROM drug_costs
WHERE running_total <= grand_total * 0.80  -- Drugs contributing to first 80% of cost
ORDER BY drug_rank;

-- Prescribers contributing to 80% of total cost
WITH prescriber_costs AS (
    SELECT 
        Prscrbr_NPI,
        Prscrbr_Last_Org_Name,
        Prscrbr_Type,
        SUM(Tot_Drug_Cst) as prescriber_cost,
        SUM(SUM(Tot_Drug_Cst)) OVER (ORDER BY SUM(Tot_Drug_Cst) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total,
        SUM(SUM(Tot_Drug_Cst)) OVER () as grand_total
    FROM medicare_prescriptions
    WHERE Prscrbr_State_Abrvtn = 'NJ'
    GROUP BY Prscrbr_NPI, Prscrbr_Last_Org_Name, Prscrbr_Type
)
SELECT 
    Prscrbr_NPI,
    Prscrbr_Last_Org_Name,
    Prscrbr_Type,
    ROUND(prescriber_cost, 0) as prescriber_cost,
    ROUND(running_total * 100.0 / grand_total, 2) as cumulative_pct,
    ROW_NUMBER() OVER (ORDER BY prescriber_cost DESC) as prescriber_rank
FROM prescriber_costs
WHERE running_total <= grand_total * 0.80
ORDER BY prescriber_rank;


-- =============================================================================
-- 10. CORRELATION ANALYSIS
-- =============================================================================

-- Relationship between prescriber volume and cost efficiency
SELECT 
    CASE 
        WHEN SUM(Tot_Clms) < 100 THEN '< 100 claims'
        WHEN SUM(Tot_Clms) < 500 THEN '100-500 claims'
        WHEN SUM(Tot_Clms) < 1000 THEN '500-1,000 claims'
        WHEN SUM(Tot_Clms) < 5000 THEN '1,000-5,000 claims'
        ELSE '5,000+ claims'
    END as volume_tier,
    COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
    ROUND(AVG(SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0)), 2) as avg_cost_per_claim,
    ROUND(AVG(COUNT(CASE WHEN LOWER(Brnd_Name) = LOWER(Gnrc_Name) THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)), 2) as avg_gdr
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Prscrbr_NPI
HAVING SUM(Tot_Clms) > 0
GROUP BY 1
ORDER BY 
    CASE 
        WHEN SUM(Tot_Clms) < 100 THEN 1
        WHEN SUM(Tot_Clms) < 500 THEN 2
        WHEN SUM(Tot_Clms) < 1000 THEN 3
        WHEN SUM(Tot_Clms) < 5000 THEN 4
        ELSE 5
    END;

-- ============================================================================
-- END OF EXPLORATORY ANALYSIS
-- ============================================================================
