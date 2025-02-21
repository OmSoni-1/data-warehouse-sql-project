/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

EXEC silver.load_silver;

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @proc_start_time DATETIME, @start_time DATETIME, @end_time DATETIME, @proc_end_time DATETIME
	BEGIN TRY
		SET @proc_start_time = GETDATE()

		PRINT '================================================';
		PRINT 'Loading Silver Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';
--1 crm_cust_info

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info 
		(
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

		SET @end_time = GETDATE()
		PRINT 'Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------'
		-----------------------------------------------------------------------------------------------------
--2 crm_prd_info

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting Data Into: silver.crm_prd_info';
		
		INSERT INTO silver.crm_prd_info
		(
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

		SET @end_time = GETDATE()
		PRINT 'Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------'
		-----------------------------------------------------------------------------------------------------
--3 crm_sales_details

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting Data Into: silver.crm_sales_details';
		
		INSERT INTO silver.crm_sales_details
		(
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

		SET @end_time = GETDATE()
		PRINT 'Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------'
		-----------------------------------------------------------------------------------------------------
-- 4 erp_cust_az12
		
		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting Data Into: silver.erp_cust_az12';
		
		Insert into silver.erp_cust_az12 
		(
			cid,
			bdate,
			gen
		)

		Select 
		CASE WHEN cid LIKE('NAS%') THEN SUBSTRING(cid, 4, LEN(cid))
			 ELSE cid
		END as CID,
		CASE WHEN bdate > GETDATE() THEN NULL
			 ELSE bdate
		END as bdate,
		CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			 ELSE 'n/a'
		END as gen
		from bronze.erp_cust_az12

		SET @end_time = GETDATE()
		PRINT 'Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------'
		-----------------------------------------------------------------------------------------------------
-- 5 erp_loc_a101

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting Data Into: silver.erp_loc_a101';
		
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

		SET @end_time = GETDATE()
		PRINT 'Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------'
		-----------------------------------------------------------------------------------------------------
-- 6 erp_px_cat_g1v2

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		
		INSERT INTO silver.erp_px_cat_g1v2 
		(
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

		SET @end_time = GETDATE()
		PRINT 'Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------'
		-----------------------------------------------------------------------------------------------------

		SET @proc_end_time = GETDATE()
		PRINT '================================================';
		PRINT 'Silver Layer Load Complete';
		PRINT 'Total Load Time: ' + CAST(DATEDIFF(second, @proc_start_time, @proc_end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================================';

	END TRY
	BEGIN CATCH
		PRINT '================================================';
		PRINT 'ERROR OCCURED DURING LOADING THE SILVER LAYER'
		PRINT 'Error Message: ' + ERROR_MESSAGE()
		PRINT 'Error Code: ' + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR)
		PRINT '================================================';
	END CATCH
END;
