-- Data Integration
-- Gender

Select DISTINCT
	ci.cst_gndr,
	caz.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master Data Source
		 ELSE COALESCE(caz.gen, 'n/a')		
	END as new_gen
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 caz
ON ci.cst_key = caz.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1, 2;

--select * from silver.erp_loc_a101

-- Test to find any Duplicates
Select cst_id, COUNT(*)
from(
	Select 
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname, 
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
		caz.bdate,
		caz.gen,
		la.cntry
	from silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 caz
	ON ci.cst_key = caz.cid
	LEFT JOIN silver.erp_loc_a101 la
	ON ci.cst_key = la.cid
) t
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- Quality Checks on the Customer Dimension View
-- Gender where we performed Data Integration
Select DISTINCT gender from gold_dim_customers
