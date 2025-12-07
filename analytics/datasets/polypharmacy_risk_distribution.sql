SELECT 
  Prscrbr_NPI,
  COUNT(DISTINCT Gnrc_Name) as drugs_per_prescriber,
  SUM(Tot_Benes) / NULLIF(COUNT(DISTINCT Gnrc_Name), 0) as avg_patients_per_drug
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
GROUP BY Prscrbr_NPI
