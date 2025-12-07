SELECT 
  Prscrbr_NPI,
  Prscrbr_Last_Org_Name,
  Prscrbr_Type,
  SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0) as cost_per_claim,
  COUNT(CASE WHEN LOWER(Brnd_Name) = LOWER(Gnrc_Name) THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) as gdr,
  SUM(Tot_Clms) as volume,
  SUM(Tot_Drug_Cst) as total_cost
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Prscrbr_NPI, Prscrbr_Last_Org_Name, Prscrbr_Type
HAVING SUM(Tot_Clms) > 200
