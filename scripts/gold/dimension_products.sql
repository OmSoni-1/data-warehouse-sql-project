CREATE OR ALTER VIEW gold.dim_products AS
Select 
	ROW_NUMBER() OVER(ORDER BY pr.prd_start_dt, pr.prd_key) as product_key, -- Surrogate Key
	pr.prd_id AS product_id,
	pr.prd_key AS product_number,
	pr.prd_nm AS product_name,
	pr.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,	
	pc.maintenance AS maintenance,
	pr.prd_cost AS cost,
	pr.prd_line AS product_line,
	pr.prd_start_dt AS start_date
from silver.crm_prd_info pr
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pr.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filtering out all the Historical data and keeping only the current products. 
