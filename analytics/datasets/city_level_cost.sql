SELECT 
  Prscrbr_City,
  SUM(Tot_Drug_Cst) as city_total_cost,
  SUM(Tot_Clms) as city_claims,
  COUNT(DISTINCT Prscrbr_NPI) as prescriber_count,
  SUM(Tot_Drug_Cst) / NULLIF(SUM(Tot_Clms), 0) as city_avg_cpc
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Prscrbr_City
HAVING SUM(Tot_Clms) > 500
