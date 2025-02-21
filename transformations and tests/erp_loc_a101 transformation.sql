INSERT INTO silver.erp_loc_a101
(
	cid,
	cntry
)

Select 
REPLACE(cid, '-', '') as cid,
CASE
	WHEN UPPER(TRIM(cntry)) in ('US', 'USA', 'UNITED STATES') THEN 'United States'
	WHEN UPPER(TRIM(cntry)) in ('DE', 'GERMANY') THEN 'Germany'
	WHEN UPPER(TRIM(cntry)) in ('AUS', 'AUSTRALIA') THEN 'Australia'
	WHEN UPPER(TRIM(cntry)) in ('CA', 'CANADA') THEN 'Canada'
	WHEN UPPER(TRIM(cntry)) in ('FR', 'FRANCE') THEN 'France'
	WHEN TRIM(cntry) = '' or cntry IS NULL THEN 'n/a'
	ELSE TRIM(cntry)
END as cntry
from bronze.erp_loc_a101;


-- Quality Checks
-- Check for ountry names to be in proper format
Select DISTINCT cntry from silver.erp_loc_a101;
