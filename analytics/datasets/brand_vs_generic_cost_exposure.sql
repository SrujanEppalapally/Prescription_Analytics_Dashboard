SELECT 
  CASE 
    WHEN LOWER(Brnd_Name) = LOWER(Gnrc_Name) THEN 'Generic'
    ELSE 'Brand'
  END as drug_type,
  CASE 
    WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) > 600 THEN 'Specialty (>$600/claim)'
    WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) > 100 THEN 'Mid-Tier ($100-$600)'
    ELSE 'Low-Tier (<$100)'
  END as cost_tier,
  Prscrbr_Type as prescriber_specialty,
  SUM(Tot_Drug_Cst) as total_cost
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY 1, 2, 3
