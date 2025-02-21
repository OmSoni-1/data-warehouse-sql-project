INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status, 
	cst_gndr, 
	cst_create_date
)

Select 
cst_id,
cst_key,
-- Removing unwanted spaces
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,

-- Standardization of Columns
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
	 WHEN UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
	 ELSE 'n/a'
END as cst_marital_status,

CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
	 WHEN UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
	 ELSE 'n/a'
END as cst_gndr,
cst_create_date
from (
-- Transformation to remove any Duplicates from the table based on the Primary Key 'cst_id'
Select *, 
ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info
where cst_id is not null
) t
where flag_last = 1


-- Select * from silver.crm_cust_info;

-- Quality Checks
-- Check for NULLS and Duplicates in the Primary Key
-- Expectation: Empty Table/ No Result

-- 1. Check for the Duplicates
-- Expectation: Empty Table/ No Result
Select cst_id, count(*) as occurrence
from silver.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is NULL;

-- 2. Check for Unwanted Spaces
-- Expectation: Empty Table/ No Result
Select cst_firstname
from silver.crm_cust_info 
where cst_firstname != TRIM(cst_firstname);

-- 3. Check for NULLs in Primary Key
-- Expectation: Empty Table/ No Result
Select cst_id
from silver.crm_cust_info
where cst_id is NULL;

-- 4. Data Standardization and Consistency
SELECT DISTINCT cst_marital_status
from silver.crm_cust_info;
