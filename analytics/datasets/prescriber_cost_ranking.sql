SELECT 
  Prscrbr_Type as specialty,
  CASE 
    WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) > 600 THEN 'Specialty'
    WHEN Tot_Drug_Cst / NULLIF(Tot_Clms, 0) > 100 THEN 'Mid-Tier'
    ELSE 'Generic-Heavy'
  END as cost_category,
  COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
  SUM(Tot_Drug_Cst) as total_cost,
  AVG(Tot_Drug_Cst / NULLIF(Tot_Clms, 0)) as avg_cost_per_claim
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY 1, 2
