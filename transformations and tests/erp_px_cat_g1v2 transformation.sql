INSERT INTO silver.erp_px_cat_g1v2 (
id,
cat,
subcat,
maintenance
)

Select 
id,
cat,
subcat,
maintenance
from bronze.erp_px_cat_g1v2



-- Quality Checks
-- 1. Check for unwanted spaces
-- Expectation: Empty Table/ No Result
Select * from bronze.erp_px_cat_g1v2
where TRIM(cat) != cat or TRIM(subcat) != subcat or TRIM(maintenance) != maintenance;

-- 2. Data Standardization and Consistency
-- Expectation: Proper values from categories, subcategories and maintenance 
Select DISTINCT cat 
from bronze.erp_px_cat_g1v2;

Select DISTINCT subcat 
from bronze.erp_px_cat_g1v2;

Select DISTINCT maintenance 
from bronze.erp_px_cat_g1v2;
