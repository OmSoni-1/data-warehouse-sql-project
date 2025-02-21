Insert into silver.erp_cust_az12 
(cid,
bdate,
gen
)

Select 
CASE WHEN cid LIKE('NAS%') THEN SUBSTRING(cid, 4, LEN(cid))
	 ELSE cid
END as CID,
CASE WHEN bdate > GETDATE() THEN NULL
	 ELSE bdate
END as bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'n/a'
END as gen
from bronze.erp_cust_az12

-- Quality Checks
-- 1. Check for Impossible Birthdays
-- Expectation: Empty Table/ No Result
Select bdate
from silver.erp_cust_az12
where bdate > GETDATE()

-- 2. Check for the Gender
-- Expectation: Proper Genders in Male/Female and n/a wherever the information is not available
Select DISTINCT gen
from silver.erp_cust_az12;
