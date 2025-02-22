CREATE OR ALTER VIEW gold.fact_sales AS

Select 
	sd.sls_ord_num AS order_number,
	gpr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
from silver.crm_sales_details sd
LEFT JOIN gold.dim_products gpr
ON sd.sls_prd_key = gpr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id
