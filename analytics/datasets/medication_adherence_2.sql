SELECT
  Prscrbr_Type AS specialty,
  (Tot_Day_Suply * 1.0 / Tot_Clms) AS days_supply_per_claim
FROM medicare_prescriptions
WHERE Prscrbr_State_Abrvtn = 'NJ'
  AND Tot_Clms > 0
  AND Tot_Day_Suply > 0
