INSERT INTO silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)

Select 
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id,
SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key,
prd_nm,
ISNULL(prd_cost, 0) as prd_cost,
-- Using Quick Case
Case UPPER(TRIM(prd_line))
	 WHEN 'M' THEN 'Mountain'
	 WHEN 'R' THEN 'Road'
	 WHEN 'S' THEN 'Other Sales'
	 WHEN 'T' THEN 'Touring'
	 ELSE 'n/a'
END as prd_line,
CAST(prd_start_dt AS DATE) as prd_start_dt,
CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key order by prd_start_dt) - 1 AS DATE) as prd_end_dt
from
bronze.crm_prd_info;

select * from silver.crm_prd_info;

--------------------------------------------------------------------------------------------------------

-- Quality Checks
-- Check for NULLS and Duplicates in the Primary Key
-- Expectation: Empty Table/ No Result

-- 1. Check for the Duplicates
-- Expectation: Empty Table/ No Result
Select prd_id, count(*) as occurrence
from silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is NULL;

-- 2. Check for Unwanted Spaces
-- Expectation: Empty Table/ No Result
Select prd_nm 
from silver.crm_prd_info 
where prd_nm != TRIM(prd_nm);

-- 3. Check for NULLs or Negative Numbers
-- Expectation: Empty Table/ No Result
Select prd_cost
from silver.crm_prd_info 
where prd_cost < 0 or prd_cost is NULL;

-- 4. Data Standardization and Consistency
SELECT DISTINCT prd_line
from silver.crm_prd_info;

-- 5. Check for Invalid Dates
-- Expectation: Empty Table/ No Result
Select * 
from silver.crm_prd_info 
where prd_start_dt > prd_end_dt;
