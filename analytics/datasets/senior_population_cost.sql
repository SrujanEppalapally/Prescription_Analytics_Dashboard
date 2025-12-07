SELECT 
  Prscrbr_Type AS specialty,
  SUM(GE65_Tot_Drug_Cst) AS senior_cost,
  (SUM(Tot_Drug_Cst) - SUM(GE65_Tot_Drug_Cst)) AS non_senior_cost,
  SUM(GE65_Tot_Drug_Cst) * 100.0 / NULLIF(SUM(Tot_Drug_Cst), 0) AS senior_cost_pct,
  SUM(GE65_Tot_Benes) AS senior_patients,
  (SUM(Tot_Benes) - SUM(GE65_Tot_Benes)) AS non_senior_patients,
  SUM(Tot_Drug_Cst) AS total_cost
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
  --AND GE65_Sprsn_Flag != '*'
GROUP BY Prscrbr_Type
HAVING SUM(Tot_Drug_Cst) > 100000
ORDER BY senior_cost_pct DESC;
