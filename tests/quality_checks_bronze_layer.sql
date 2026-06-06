USE dwarehouse_project_bronze;

-- ------------------------------------------;
-- ------  CRM CUST INFO TABLE  ------;
-- ------------------------------------------;

SELECT * FROM crm_cust_info;

-- Checks for NULLS and Duplicates in Primary Key
-- Expectations: No Result

SELECT cst_id, COUNT(*) 
	FROM crm_cust_info 
	GROUP BY cst_id 
		HAVING COUNT(*) > 1 OR cst_id IS NULL;
        

-- Checks for Unwanted spaces
-- Expectations: No Result

SELECT * FROM crm_cust_info
	WHERE cst_key != TRIM(cst_key);

SELECT * FROM crm_cust_info
	WHERE cst_firstname != TRIM(cst_firstname);
    
SELECT * FROM crm_cust_info
	WHERE cst_lastname != TRIM(cst_lastname);
    
SELECT * FROM crm_cust_info
	WHERE cst_material_status != TRIM(cst_material_status);
    
SELECT * FROM crm_cust_info
	WHERE cst_gndr != TRIM(cst_gndr);
    
-- DATA Standardisation and Consistency
-- Expectations: No Result

SELECT DISTINCT(cst_material_status) FROM crm_cust_info;
SELECT DISTINCT(cst_gndr) FROM crm_cust_info;


-- ------------------------------------------;
-- ------  CRM PRD INFO TABLE  ------;
-- ------------------------------------------;

-- Checks for NULLS and Duplicates in Primary Key
-- Expectations: No Result

SELECT prd_id, COUNT(*) 
	FROM crm_prd_info 
	GROUP BY prd_id 
		HAVING COUNT(*) > 1 OR prd_id IS NULL;
        
-- Checks for prd_id 0, NULL or Negative
-- Expectations: No Result

SELECT * FROM crm_prd_info
	WHERE prd_id <= 0 OR prd_id IS NULL;
    
-- Checks prd_key has spaces
-- Expectations: No Result

SELECT * FROM crm_prd_info
	WHERE prd_key != TRIM(prd_key);

-- Checks prd_key has spaces
-- Expectations: No Result

SELECT * FROM crm_prd_info
	WHERE prd_nm != TRIM(prd_nm);

-- Checks for prd_id 0, NULL or Negative
-- Expectations: No Result

SELECT * FROM crm_prd_info
	WHERE prd_cost < 0 OR prd_cost IS NULL;
    
-- Checks for DISTINCT values in prd_line
-- Expectations: Only unique values in UPPERCASE or LOWERCASE

SELECT DISTINCT(prd_line) FROM crm_prd_info; -- Change short names to clear full names

-- Check if prd_start_dt is greater than prd_end_dt
-- Expectations: No Result

SELECT * FROM crm_prd_info
	WHERE prd_end_dt < prd_start_dt OR prd_start_dt = 0;
    


-- ------------------------------------------;
-- -----  CRM SALES DETAILS INFO TABLE  -----;
-- ------------------------------------------;

-- Checks sls_ord_num and sls_prd_key has spaces
-- Expectations: No Result

SELECT * FROM crm_sales_details
	WHERE sls_ord_num != TRIM(sls_ord_num);
    
SELECT * FROM crm_sales_details
	WHERE sls_prd_key != TRIM(sls_prd_key);
    
-- Check for invalid Dates Formats and Values
-- Expectations: No Result

SELECT * FROM crm_sales_details
	WHERE sls_order_dt <= 0 OR LENGTH(sls_order_dt) != 8;

SELECT * FROM crm_sales_details
	WHERE sls_ship_dt <= 0 OR LENGTH(sls_ship_dt) != 8;

SELECT * FROM crm_sales_details
	WHERE sls_due_dt <= 0 OR LENGTH(sls_due_dt) != 8;


-- Check for invalid Dates: sls_order_dt > sls_ship_dt or sls_due_dt
-- Expectations: No Result

SELECT * FROM crm_sales_details
	WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


-- Check Data Consistency: Between sales, quantity and price
-- Expectations: >> Sales = Quantity * price
--               >> Must not be Null, 0 or Negative

SELECT * FROM crm_sales_details
	WHERE sls_sales != sls_quantity * sls_price
	  OR  sls_sales IS NULL OR sls_quantity IS NULL OR  sls_price IS NULL
      OR  sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
      ORDER BY sls_sales, sls_quantity, sls_price;
    


-- ------------------------------------------;
-- ----------  ERP CUST A12 TABLE  ----------;
-- ------------------------------------------;

-- Check consistency of cid column

SELECT DISTINCT(cid) FROM erp_cust_a12 WHERE cid NOT LIKE "NAS%";


-- Checking invalid dates like bdate > NOW()
-- Expectations: No Result

SELECT * FROM erp_cust_a12
	WHERE bdate > NOW();
    
    
-- Checking for different multiple values for same thing
-- Expectations: 1 value for 1 gender

SELECT DISTINCT(gen), LENGTH(gen) FROM erp_cust_a12;


-- ------------------------------------------;
-- --------  ERP LOCAL A 101 TABLE  ---------;
-- ------------------------------------------;

-- Checking for different multiple values for same thing
-- Expectations: 1 value for 1 country

SELECT DISTINCT(cntry), LENGTH(cntry) FROM  erp_local_a_101;


-- ------------------------------------------;
-- -----------  ERP PX CAT G1V2  ------------;
-- ------------------------------------------;

-- Checking for different multiple values for same thing
-- Expectations: 1 value for 1 country

-- Checks Empty spaces
-- Expectations: No Result

SELECT id FROM erp_px_cat_g1v2
	WHERE id != TRIM(id);
    
SELECT cat FROM erp_px_cat_g1v2
	WHERE cat != TRIM(cat);
    
SELECT subcat FROM erp_px_cat_g1v2
	WHERE subcat != TRIM(subcat);
    
SELECT maintenance FROM erp_px_cat_g1v2
	WHERE maintenance != TRIM(maintenance);
    

-- Checks duplicate categories
-- Expectations: No Result

SELECT DISTINCT(cat), LENGTH(cat) FROM erp_px_cat_g1v2;
SELECT DISTINCT(subcat), LENGTH(subcat) FROM erp_px_cat_g1v2;
SELECT DISTINCT(maintenance), LENGTH(maintenance) FROM erp_px_cat_g1v2;