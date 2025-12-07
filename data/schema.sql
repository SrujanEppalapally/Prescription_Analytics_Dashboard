
CREATE TABLE medicare_prescriptions (
	Prscrbr_NPI VARCHAR(20),
	Prscrbr_Last_Org_Name VARCHAR(200),
	Prscrbr_First_Name VARCHAR(100),
	Prscrbr_City VARCHAR(100),
	Prscrbr_State_Abrvtn VARCHAR(2),
	Prscrbr_State_FIPS INTEGER,
	Prscrbr_Type VARCHAR(100),
	Prscrbr_Type_Src VARCHAR(200),
	Brnd_Name VARCHAR(200),
	Gnrc_Name VARCHAR(200),
	Tot_Clms INTEGER,
	Tot_30day_Fills NUMERIC,
	Tot_Day_Suply INTEGER,
	Tot_Drug_Cst NUMERIC,
	Tot_Benes NUMERIC,
	GE65_Sprsn_Flag VARCHAR(2),
	GE65_Tot_Clms INTEGER,
	GE65_Tot_30day_Fills NUMERIC,
	GE65_Tot_Drug_Cst NUMERIC,
	GE65_Tot_Day_Suply INTEGER,
	GE65_Bene_Sprsn_Flag VARCHAR(2),
	GE65_Tot_Benes INTEGER
);



CREATE INDEX idx_state ON medicare_prescriptions(prscrbr_state_abrvtn);
CREATE INDEX idx_drug ON medicare_prescriptions(brnd_name);
CREATE INDEX idx_prescriber ON medicare_prescriptions(prscrbr_npi);
CREATE INDEX idx_cost ON medicare_prescriptions(tot_drug_cst);