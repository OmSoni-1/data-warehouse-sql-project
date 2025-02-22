CREATE OR ALTER VIEW gold.dim_customers AS

Select 
	ROW_NUMBER() OVER(ORDER BY cst_id) as customer_key, -- Surrogate Key
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name, 
	la.cntry AS country,	
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master Data Source
		 ELSE COALESCE(caz.gen, 'n/a')		
	END AS gender,
	ci.cst_marital_status as marital_status,
	caz.bdate AS birtddate,
	ci.cst_create_date AS create_date
	
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 caz
ON ci.cst_key = caz.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;
