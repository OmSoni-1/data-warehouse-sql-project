-- Checking if the product keys have duplicates in the record
-- Expectations: Empty Table or No records

Select prd_key, COUNT(*) from
(
	Select 
		pr.prd_id,
		pr.cat_id,
		pr.prd_key,
		pr.prd_nm,
		pr.prd_cost,
		pr.prd_line,
		pr.prd_start_dt,
		pc.cat,
		pc.subcat,
		pc.maintenance
	from silver.crm_prd_info pr
	LEFT JOIN silver.erp_px_cat_g1v2 pc
	ON pr.cat_id = pc.id
	WHERE prd_end_dt IS NULL
) t 
GROUP BY prd_key
HAVING COUNT(*) > 1;

Select * from gold.dim_products;
