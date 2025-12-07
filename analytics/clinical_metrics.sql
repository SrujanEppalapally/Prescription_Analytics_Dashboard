-- ============================================================================
-- CLINICAL METRICS - KPI SQL LIBRARY
-- Prescription Analytics Platform
-- ============================================================================
-- Purpose: SQL queries for clinical quality and patient safety indicators
-- Dataset: Medicare Part D Prescriptions (New Jersey)
-- Category: Quality, Adherence, Safety, and Outcomes
-- ============================================================================

-- =============================================================================
-- CLINICAL QUALITY KPIs
-- =============================================================================

-- KPI 1: Generic Dispensing Rate (GDR)
-- Description: Percentage of prescriptions filled with generic equivalent
-- Usage: Big Number chart, quality scorecard
SELECT 
    COUNT(CASE WHEN LOWER(TRIM(Brnd_Name)) = LOWER(TRIM(Gnrc_Name)) THEN 1 END) as generic_count,
    COUNT(*) as total_prescriptions,
    ROUND(COUNT(CASE WHEN LOWER(TRIM(Brnd_Name)) = LOWER(TRIM(Gnrc_Name)) THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2) as generic_dispensing_rate,
    'Generic Dispensing Rate' as metric_name,
    CASE 
        WHEN COUNT(CASE WHEN LOWER(TRIM(Brnd_Name)) = LOWER(TRIM(Gnrc_Name)) THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 85 THEN 'Green - On Target'
        WHEN COUNT(CASE WHEN LOWER(TRIM(Brnd_Name)) = LOWER(TRIM(Gnrc_Name)) THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 75 THEN 'Yellow - Monitor'
        ELSE 'Red - Action Required'
    END as status
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ';


-- KPI 2: Average Days Supply Per Claim (Adherence Proxy)
-- Description: Average prescription duration indicating fill patterns
-- Usage: Adherence monitoring, 90-day fill program ROI
SELECT 
    ROUND(SUM(Tot_Day_Suply) / NULLIF(SUM(Tot_Clms), 0), 1) as avg_days_supply_per_claim,
    'Average Days Supply' as metric_name,
    CASE 
        WHEN SUM(Tot_Day_Suply) / NULLIF(SUM(Tot_Clms), 0) >= 60 THEN 'Green - Optimal Adherence'
        WHEN SUM(Tot_Day_Suply) / NULLIF(SUM(Tot_Clms), 0) >= 30 THEN 'Yellow - Standard Fill'
        ELSE 'Red - Poor Adherence Risk'
    END as status
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Clms > 0
    AND Tot_Day_Suply > 0;


-- KPI 3: Medication Possession Ratio (MPR) Estimate
-- Description: Proportion of days patient has medication available
-- Usage: Adherence program targeting, quality star ratings
SELECT 
    ROUND(SUM(Tot_30day_Fills) / NULLIF(SUM(Tot_Day_Suply) / 30, 0) * 100, 2) as estimated_mpr,
    'Medication Possession Ratio (Est.)' as metric_name,
    CASE 
        WHEN SUM(Tot_30day_Fills) / NULLIF(SUM(Tot_Day_Suply) / 30, 0) >= 0.80 THEN 'Green - Adherent'
        WHEN SUM(Tot_30day_Fills) / NULLIF(SUM(Tot_Day_Suply) / 30, 0) >= 0.60 THEN 'Yellow - Partially Adherent'
        ELSE 'Red - Non-Adherent'
    END as adherence_status
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Day_Suply > 0;


-- KPI 4: Claims Per Beneficiary (Utilization Index)
-- Description: Average number of prescriptions per unique member
-- Usage: Utilization management, polypharmacy screening
SELECT 
    SUM(Tot_Clms) as total_claims,
    SUM(Tot_Benes) as total_beneficiaries,
    ROUND(SUM(Tot_Clms) * 1.0 / NULLIF(SUM(Tot_Benes), 0), 2) as claims_per_beneficiary,
    'Claims Per Beneficiary' as metric_name,
    CASE 
        WHEN SUM(Tot_Clms) * 1.0 / NULLIF(SUM(Tot_Benes), 0) > 25 THEN 'Red - Overutilization Risk'
        WHEN SUM(Tot_Clms) * 1.0 / NULLIF(SUM(Tot_Benes), 0) > 18 THEN 'Yellow - Monitor'
        ELSE 'Green - Normal Range'
    END as status
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Benes > 0;


-- =============================================================================
-- PATIENT SAFETY METRICS
-- =============================================================================

-- KPI 5: Polypharmacy Risk Index
-- Description: % of prescribers with high drug diversity (proxy for patient polypharmacy)
-- Usage: Clinical pharmacist intervention targeting
WITH prescriber_drug_counts AS (
    SELECT 
        Prscrbr_NPI,
        COUNT(DISTINCT Gnrc_Name) as unique_drugs,
        SUM(Tot_Benes) as total_patients
    FROM medicare_prescriptions
    WHERE Prscrbr_State_Abrvtn = 'NJ'
    GROUP BY Prscrbr_NPI
)
SELECT 
    COUNT(*) as total_prescribers,
    COUNT(CASE WHEN unique_drugs >= 50 THEN 1 END) as high_diversity_prescribers,
    ROUND(COUNT(CASE WHEN unique_drugs >= 50 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2) as high_diversity_pct,
    ROUND(AVG(unique_drugs), 1) as avg_drugs_per_prescriber,
    'Polypharmacy Risk Index' as metric_name
FROM prescriber_drug_counts;


-- KPI 6: 90-Day Fill Adoption Rate
-- Description: % of prescriptions with 60+ days supply (optimal adherence pattern)
-- Usage: Adherence program performance, mail-order optimization
SELECT 
    COUNT(CASE WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) >= 60 THEN 1 END) as long_fill_count,
    COUNT(*) as total_records,
    ROUND(COUNT(CASE WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) >= 60 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2) as ninety_day_fill_rate,
    '90-Day Fill Adoption Rate' as metric_name,
    CASE 
        WHEN COUNT(CASE WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) >= 60 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 35 THEN 'Green - High Adoption'
        WHEN COUNT(CASE WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) >= 60 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 20 THEN 'Yellow - Growing'
        ELSE 'Red - Low Adoption'
    END as status
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Clms > 0
    AND Tot_Day_Suply > 0;


-- =============================================================================
-- PRESCRIBER QUALITY METRICS
-- =============================================================================

-- KPI 7: Prescriber Generic Dispensing Rate by Specialty
-- Description: Generic rate by medical specialty
-- Usage: Identify specialties requiring education/incentives
SELECT 
    Prscrbr_Type as specialty,
    COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
    COUNT(*) as total_records,
    COUNT(CASE WHEN LOWER(TRIM(Brnd_Name)) = LOWER(TRIM(Gnrc_Name)) THEN 1 END) as generic_count,
    ROUND(COUNT(CASE WHEN LOWER(TRIM(Brnd_Name)) = LOWER(TRIM(Gnrc_Name)) THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2) as specialty_gdr,
    ROUND(SUM(Tot_Drug_Cst), 0) as specialty_total_cost,
    'Specialty-Level GDR' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Prscrbr_Type
HAVING COUNT(DISTINCT Prscrbr_NPI) >= 5
ORDER BY specialty_gdr ASC;  -- Lowest GDR first (improvement opportunities)


-- KPI 8: Prescriber Adherence Support Score
-- Description: Average days supply by prescriber (proxy for adherence support)
-- Usage: Prescriber profiling, best practice identification
SELECT 
    Prscrbr_NPI,
    Prscrbr_Last_Org_Name,
    Prscrbr_Type,
    SUM(Tot_Clms) as total_claims,
    ROUND(SUM(Tot_Day_Suply) / NULLIF(SUM(Tot_Clms), 0), 1) as avg_days_supply,
    ROUND(SUM(Tot_30day_Fills) / NULLIF(SUM(Tot_Day_Suply) / 30, 0) * 100, 1) as estimated_mpr,
    'Adherence Support Score' as metric_name,
    CASE 
        WHEN SUM(Tot_Day_Suply) / NULLIF(SUM(Tot_Clms), 0) >= 60 THEN 'High Support'
        WHEN SUM(Tot_Day_Suply) / NULLIF(SUM(Tot_Clms), 0) >= 45 THEN 'Moderate Support'
        ELSE 'Low Support'
    END as support_tier
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Clms > 100  -- Minimum volume
GROUP BY Prscrbr_NPI, Prscrbr_Last_Org_Name, Prscrbr_Type
ORDER BY avg_days_supply DESC
LIMIT 100;


-- =============================================================================
-- SENIOR POPULATION CLINICAL METRICS
-- =============================================================================

-- KPI 9: Senior Utilization Rate
-- Description: Claims per senior beneficiary vs. overall population
-- Usage: Medicare Star Ratings, Part D plan design
SELECT 
    SUM(GE65_Tot_Clms) as senior_claims,
    SUM(GE65_Tot_Benes) as senior_beneficiaries,
    ROUND(SUM(GE65_Tot_Clms) * 1.0 / NULLIF(SUM(GE65_Tot_Benes), 0), 2) as senior_claims_per_bene,
    SUM(Tot_Clms) - SUM(GE65_Tot_Clms) as non_senior_claims,
    SUM(Tot_Benes) - SUM(GE65_Tot_Benes) as non_senior_beneficiaries,
    ROUND((SUM(Tot_Clms) - SUM(GE65_Tot_Clms)) * 1.0 / NULLIF(SUM(Tot_Benes) - SUM(GE65_Tot_Benes), 0), 2) as non_senior_claims_per_bene,
    'Senior Utilization Rate' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND GE65_Sprsn_Flag != '*';


-- KPI 10: Senior Medication Intensity
-- Description: Average days supply for 65+ population
-- Usage: Medicare quality measures, chronic care management
SELECT 
    ROUND(SUM(GE65_Tot_Day_Suply) / NULLIF(SUM(GE65_Tot_Clms), 0), 1) as senior_avg_days_supply,
    ROUND((SUM(Tot_Day_Suply) - SUM(GE65_Tot_Day_Suply)) / NULLIF(SUM(Tot_Clms) - SUM(GE65_Tot_Clms), 0), 1) as non_senior_avg_days_supply,
    'Senior Medication Intensity' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND GE65_Sprsn_Flag != '*'
    AND GE65_Tot_Clms > 0;


-- =============================================================================
-- ADHERENCE PATTERN ANALYSIS
-- =============================================================================

-- KPI 11: Days Supply Distribution
-- Description: Distribution of prescription lengths (adherence patterns)
-- Usage: Identify opportunities for 90-day fill programs
SELECT 
    CASE 
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 20 THEN '< 20 days (Poor)'
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 30 THEN '20-30 days (Standard)'
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 60 THEN '30-60 days (Good)'
        WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) < 90 THEN '60-90 days (Optimal)'
        ELSE '90+ days (Excellent)'
    END as days_supply_category,
    COUNT(*) as record_count,
    SUM(Tot_Clms) as total_claims,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as pct_of_records,
    ROUND(AVG(Tot_30day_Fills / NULLIF(Tot_Day_Suply / 30, 0)) * 100, 1) as avg_mpr_estimate
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


-- KPI 12: Adherence Gap Analysis by Specialty
-- Description: Specialties with lowest adherence support
-- Usage: Target specialty-specific adherence interventions
SELECT 
    Prscrbr_Type as specialty,
    COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
    ROUND(AVG(Tot_Day_Suply / NULLIF(Tot_Clms, 0)), 1) as avg_days_supply,
    ROUND(AVG(Tot_30day_Fills / NULLIF(Tot_Day_Suply / 30, 0)) * 100, 1) as avg_mpr_estimate,
    60 - ROUND(AVG(Tot_Day_Suply / NULLIF(Tot_Clms, 0)), 1) as gap_to_target,
    'Adherence Gap Analysis' as metric_name
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
    AND Tot_Clms > 0
    AND Tot_Day_Suply > 0
GROUP BY Prscrbr_Type
HAVING COUNT(DISTINCT Prscrbr_NPI) >= 5
    AND AVG(Tot_Day_Suply / NULLIF(Tot_Clms, 0)) < 60  -- Below optimal
ORDER BY gap_to_target DESC;


-- =============================================================================
-- QUALITY COMPOSITE METRICS
-- =============================================================================

-- KPI 13: Clinical Quality Index (Composite)
-- Description: Weighted composite of quality metrics
-- Usage: Provider quality rankings, pay-for-performance programs
WITH quality_components AS (
    SELECT 
        COUNT(CASE WHEN LOWER(TRIM(Brnd_Name)) = LOWER(TRIM(Gnrc_Name)) THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) as gdr,
        SUM(Tot_Day_Suply) / NULLIF(SUM(Tot_Clms), 0) / 90 * 100 as adherence_score,  -- Normalize to 0-100
        COUNT(CASE WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) >= 60 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) as ninety_day_rate
    FROM medicare_prescriptions
    WHERE Prscrbr_State_Abrvtn = 'NJ'
        AND Tot_Clms > 0
)
SELECT 
    ROUND(gdr, 2) as generic_dispensing_rate,
    ROUND(adherence_score, 2) as adherence_score,
    ROUND(ninety_day_rate, 2) as ninety_day_fill_rate,
    ROUND((gdr * 0.40) + (adherence_score * 0.30) + (ninety_day_rate * 0.30), 2) as clinical_quality_index,
    'Clinical Quality Index' as metric_name,
    CASE 
        WHEN (gdr * 0.40) + (adherence_score * 0.30) + (ninety_day_rate * 0.30) >= 85 THEN 'Excellent'
        WHEN (gdr * 0.40) + (adherence_score * 0.30) + (ninety_day_rate * 0.30) >= 75 THEN 'Good'
        WHEN (gdr * 0.40) + (adherence_score * 0.30) + (ninety_day_rate * 0.30) >= 65 THEN 'Fair'
        ELSE 'Needs Improvement'
    END as quality_rating
FROM quality_components;


-- KPI 14: Prescriber Clinical Quality Ranking
-- Description: Top prescribers by composite quality score
-- Usage: Best practice identification, provider recognition programs
WITH prescriber_quality AS (
    SELECT 
        Prscrbr_NPI,
        Prscrbr_Last_Org_Name,
        Prscrbr_Type,
        SUM(Tot_Clms) as total_claims,
        COUNT(CASE WHEN LOWER(TRIM(Brnd_Name)) = LOWER(TRIM(Gnrc_Name)) THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) as gdr,
        SUM(Tot_Day_Suply) / NULLIF(SUM(Tot_Clms), 0) as avg_days_supply,
        COUNT(CASE WHEN Tot_Day_Suply / NULLIF(Tot_Clms, 0) >= 60 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) as ninety_day_rate
    FROM medicare_prescriptions
    WHERE Prscrbr_State_Abrvtn = 'NJ'
    GROUP BY Prscrbr_NPI, Prscrbr_Last_Org_Name, Prscrbr_Type
    HAVING SUM(Tot_Clms) > 100  -- Minimum volume
)
SELECT 
    Prscrbr_NPI,
    Prscrbr_Last_Org_Name,
    Prscrbr_Type,
    total_claims,
    ROUND(gdr, 2) as gdr,
    ROUND(avg_days_supply, 1) as avg_days_supply,
    ROUND(ninety_day_rate, 2) as ninety_day_rate,
    ROUND((gdr * 0.40) + ((avg_days_supply / 90 * 100) * 0.30) + (ninety_day_rate * 0.30), 2) as quality_score,
    ROW_NUMBER() OVER (ORDER BY (gdr * 0.40) + ((avg_days_supply / 90 * 100) * 0.30) + (ninety_day_rate * 0.30) DESC) as quality_rank
FROM prescriber_quality
ORDER BY quality_score DESC
LIMIT 50;


-- ============================================================================
-- END OF CLINICAL METRICS
-- ============================================================================
