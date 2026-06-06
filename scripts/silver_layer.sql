DROP SCHEMA IF EXISTS dwarehouse_project_silver;
CREATE SCHEMA dwarehouse_project_silver;
USE dwarehouse_project_bronze;
SET GLOBAL local_infile = 1;

-- SELECT '------------------  Creating crm_cust_info';
DROP TABLE IF EXISTS dwarehouse_project_silver.crm_cust_info;
CREATE TABLE dwarehouse_project_silver.crm_cust_info (
		cst_id INT,
        cst_key VARCHAR(50),
        cst_firstname VARCHAR(50),
        cst_lastname VARCHAR(50),
        cst_material_status VARCHAR(50),
        cst_gndr VARCHAR(50),
        cst_create_date DATE,
        dwh_create_date DATETIME DEFAULT NOW()
	);

TRUNCATE TABLE dwarehouse_project_silver.crm_cust_info;
INSERT INTO dwarehouse_project_silver.crm_cust_info(
	cst_id,
    cst_key,
    cst_firstname,
	cst_lastname,
    cst_material_status,
    cst_gndr,
    cst_create_date)
WITH cte AS
	(SELECT * , ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
		FROM crm_cust_info WHERE cst_id != 0)
	SELECT cst_id,
		   cst_key,
           TRIM(cst_firstname) AS cst_firstname,
           TRIM(cst_lastname) AS cst_lastname,
           CASE WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN "Single"
                WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN "Married"  -- Normalise marital status to readable format
                ELSE "N/A"
				END cst_material_status,
           CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN "Male"
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN "Female"  -- Normalise gender values to readable format
                ELSE "N/A"
				END cst_gndr,
           cst_create_date
		FROM cte WHERE flag_last = 1;  -- Select the most recent record of a customer



-- SELECT '------------------  Creating crm_prd_info';

DROP TABLE IF EXISTS dwarehouse_project_silver.crm_prd_info;
CREATE TABLE dwarehouse_project_silver.crm_prd_info (
		prd_id INT,
        cat_id VARCHAR(50),
		prd_key VARCHAR(50),
		prd_nm VARCHAR(50),
		prd_cost INT,
        prd_line VARCHAR(50),
        prd_start_dt DATE,
        prd_end_dt DATE,
        dwh_create_date DATETIME DEFAULT NOW()
	);
    
TRUNCATE TABLE dwarehouse_project_silver.crm_prd_info;
INSERT INTO dwarehouse_project_silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt)
	SELECT prd_id,
		   REPLACE(TRIM(SUBSTRING(prd_key, 1, 5)),"-","_") AS cat_id,
		   SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
		   prd_nm,
           prd_cost,
		   CASE TRIM(UPPER(prd_line)) 
				WHEN 'M' THEN "Mountain"
				WHEN 'R' THEN "Road"
				WHEN 'T' THEN "Touring"
				WHEN 'S' THEN "Other Sales"
				ELSE "N/A" END AS prd_line,
		   DATE(prd_start_dt) AS prd_start_dt,
		   DATE_SUB(DATE(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)), INTERVAL 1 DAY) AS prd_end_dt
		   FROM crm_prd_info;


-- SELECT '------------------  Creating crm_sales_details';

DROP TABLE IF EXISTS dwarehouse_project_silver.crm_sales_details;    
CREATE TABLE dwarehouse_project_silver.crm_sales_details (
		sls_ord_num VARCHAR(50),
		sls_prd_key VARCHAR(50),
		sls_cust_id INT,
		sls_order_dt DATE,
        sls_ship_dt DATE,
		sls_due_dt DATE,
        sls_sales INT,
        sls_quantity INT,
		sls_price INT ,
        dwh_create_date DATETIME DEFAULT NOW()
	);

TRUNCATE TABLE dwarehouse_project_silver.crm_sales_details;
INSERT INTO dwarehouse_project_silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
        sls_ship_dt,
		sls_due_dt,
        sls_sales,
        sls_quantity,
		sls_price)
	SELECT sls_ord_num,
		   sls_prd_key,
		   sls_cust_id,
		   CASE WHEN sls_order_dt <= 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
				ELSE STR_TO_DATE(sls_order_dt,"%Y%m%d")
				END sls_order_dt,
		   CASE WHEN sls_ship_dt <= 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
				ELSE STR_TO_DATE(sls_ship_dt,"%Y%m%d")
				END sls_ship_dt,
		   CASE WHEN sls_due_dt <= 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
				ELSE STR_TO_DATE(sls_due_dt,"%Y%m%d")
				END sls_due_dt,
		   CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(NULLIF(sls_price,0)) THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
				END sls_sales,
		   sls_quantity,
		   CASE WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales/NULLIF(sls_quantity,0)
				ELSE sls_price
				END sls_price
		   FROM crm_sales_details;


-- SELECT '------------------------------------------';
-- SELECT '------  CREATE AND LOAD ERP SCHEMA  ------';
-- SELECT '------------------------------------------';

-- SELECT '----------------  Creating erp_local_a_101';

DROP TABLE IF EXISTS dwarehouse_project_silver.erp_local_a_101;
CREATE TABLE dwarehouse_project_silver.erp_local_a_101(
		cid VARCHAR(50),
        cntry VARCHAR(50),
        dwh_create_date DATETIME DEFAULT NOW()
	);

TRUNCATE TABLE dwarehouse_project_silver.erp_local_a_101;
INSERT INTO dwarehouse_project_silver.erp_local_a_101(
	cid,
    cntry)
	SELECT 
		TRIM(REPLACE(cid, '-', "")) AS cid,
		CASE WHEN UPPER(TRIM(REPLACE(cntry,"\r",""))) IN ("US", "USA") THEN "United States" 
			 WHEN UPPER(TRIM(REPLACE(cntry,"\r",""))) = "DE" THEN "Germany" 
			 WHEN UPPER(TRIM(REPLACE(cntry,"\r",""))) = "" THEN "N/A"
			 ELSE cntry 
			 END AS cntry 
		FROM erp_local_a_101;



-- SELECT '-------------------  Creating erp_cust_a12';

DROP TABLE IF EXISTS dwarehouse_project_silver.erp_cust_a12;
CREATE TABLE dwarehouse_project_silver.erp_cust_a12(
		cid VARCHAR(50),
        bdate DATE,
        gen VARCHAR(50),
        dwh_create_date DATETIME DEFAULT NOW()
	);

TRUNCATE TABLE dwarehouse_project_silver.erp_cust_a12;
INSERT INTO dwarehouse_project_silver.erp_cust_a12(
	cid,
    bdate,
    gen)
	SELECT TRIM(CASE WHEN cid LIKE "NAS%" THEN SUBSTRING(cid, 4, LENGTH(cid))
		   ELSE cid
           END) AS cid,
		   CASE WHEN bdate > NOW() OR bdate = 0 THEN null
			    ELSE bdate
			    END AS bdate,
		   CASE WHEN UPPER(TRIM(REPLACE(gen, '\r', ''))) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(REPLACE(gen, '\r', ''))) IN ('M', 'MALE')   THEN 'Male'
				ELSE 'N/A'
				END AS gen
		   FROM erp_cust_a12;


-- SELECT '-------------------  Creating erp_lpx_cat_g1v2';

DROP TABLE IF EXISTS dwarehouse_project_silver.erp_px_cat_g1v2;    
CREATE TABLE dwarehouse_project_silver.erp_px_cat_g1v2(
		id VARCHAR(50),
        cat VARCHAR(50),
        subcat VARCHAR(50),
        maintenance VARCHAR(50),
        dwh_create_date DATETIME DEFAULT NOW()
	);
    
TRUNCATE TABLE dwarehouse_project_silver.erp_px_cat_g1v2;
INSERT INTO dwarehouse_project_silver.erp_px_cat_g1v2(
	id,
    cat,
    subcat,
    maintenance)
    SELECT id,
		   cat,
		   subcat,
		   TRIM(REPLACE(maintenance,'\r','')) AS maintenance
		FROM erp_px_cat_g1v2;


