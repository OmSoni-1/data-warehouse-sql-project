INSERT INTO silver.crm_sales_details(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
)

Select 
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_order_dt as VARCHAR) AS DATE)
END as sls_order_dt,

CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_ship_dt as VARCHAR) AS DATE)
END as sls_ship_dt,

CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_due_dt as VARCHAR) AS DATE)
END as sls_due_dt,

CASE WHEN sls_sales <= 0 or sls_sales is NULL or sls_sales != sls_quantity * ABS(sls_price)
	 THEN sls_quantity * ABS(sls_price)
	 ELSE sls_sales
END as sls_sales,

sls_quantity,
CASE WHEN sls_price <= 0 or sls_price is NULL
	 THEN ABS(sls_sales / NULLIF(sls_quantity, 0))
	 ELSE sls_price
END as sls_price
from bronze.crm_sales_details

-- Quality Checks
-- 1. Check for invalid dates
-- Expectation: Empty Table/ No Result

Select sls_order_dt
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt ;

-- 2. Check Data Consistency: Sales, Quantity and Price
-- Sales = Quantity * Price
-- No column should have a NULL, Negative or a Zero as a value.
Select
sls_sales as old_sls_sales,
sls_quantity,
sls_price as old_sls_price
from silver.crm_sales_details
where
sls_sales <= 0 
or sls_quantity <= 0 
or sls_price = 0 
or sls_sales is NULL 
or sls_quantity is NULL 
or sls_price is NULL
order by sls_sales; 
