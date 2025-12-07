SELECT 
  Brnd_Name,
  SUM(Tot_Drug_Cst) as total_cost,
  SUM(Tot_Clms) as total_claims,
  SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0) as cost_per_claim,
  COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
  SUM(Tot_Benes) as affected_patients
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Brnd_Name
HAVING SUM(Tot_Clms) > 100
ORDER BY total_cost DESC
LIMIT 25
