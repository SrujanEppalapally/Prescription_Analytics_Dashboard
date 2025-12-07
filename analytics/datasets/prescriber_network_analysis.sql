SELECT 
  Prscrbr_NPI,
  Prscrbr_Last_Org_Name AS prescriber_name,
  Prscrbr_Type AS specialty,
  Prscrbr_City AS city,
  SUM(Tot_Clms) AS total_prescriptions,
  SUM(Tot_Drug_Cst) AS total_cost,
  SUM(Tot_Drug_Cst) * 1.0 / SUM(Tot_Clms) AS cost_per_claim,
  COUNT(DISTINCT COALESCE(Gnrc_Name, Brnd_Name)) AS unique_drugs,
  SUM(Tot_Benes) AS patients_served,

  -- Z-score for cost-per-claim
  (
    SUM(Tot_Drug_Cst) * 1.0 / SUM(Tot_Clms)
    - AVG(SUM(Tot_Drug_Cst) * 1.0 / SUM(Tot_Clms)) OVER ()
  ) /
  NULLIF(STDDEV(SUM(Tot_Drug_Cst) * 1.0 / SUM(Tot_Clms)) OVER (), 0)
  AS cost_z_score

FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Prscrbr_NPI, Prscrbr_Last_Org_Name, Prscrbr_Type, Prscrbr_City
HAVING SUM(Tot_Clms) > 100
ORDER BY total_cost DESC
LIMIT 100;
