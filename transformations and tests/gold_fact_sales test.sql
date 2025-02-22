-- Quality Check
-- Foreig Key Integrity Check between the Fact and the other two Dimensions
-- Expectations: Empty Table or No Records

Select * from gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE p.product_key is NULL
OR c.customer_key IS NULL;
