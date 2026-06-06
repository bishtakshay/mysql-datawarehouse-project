-- SELECT '=========================================';
-- SELECT '------------  BRONZE LAYER  -------------';
-- SELECT '=========================================';

-- SELECT '-----------  CREATE SCHEMA  -------------';
DROP SCHEMA IF EXISTS dwarehouse_project_bronze;
CREATE SCHEMA dwarehouse_project_bronze;
USE dwarehouse_project_bronze;
SET GLOBAL local_infile = 1;

-- DLL Commands for 6 Tables from 2 Data Sources (3 Tables each)


-- SELECT '------------------------------------------';
-- SELECT '------  CREATE AND LOAD CRM SCHEMA  ------';
-- SELECT '------------------------------------------';

-- SELECT '------------------  Creating crm_cust_info';
DROP TABLE IF EXISTS dwarehouse_project_bronze.crm_cust_info;
CREATE TABLE dwarehouse_project_bronze.crm_cust_info (
		cst_id INT,
        cst_key VARCHAR(50),
        cst_firstname VARCHAR(50),
        cst_lastname VARCHAR(50),
        cst_material_status VARCHAR(50),
        cst_gndr VARCHAR(50),
        cst_create_date DATE
	);

LOAD DATA LOCAL INFILE '/Users/akshaybisht/Desktop/Projects/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE dwarehouse_project_bronze.crm_cust_info
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


-- SELECT '------------------  Creating crm_prd_info';

DROP TABLE IF EXISTS dwarehouse_project_bronze.crm_prd_info;
CREATE TABLE dwarehouse_project_bronze.crm_prd_info (
		prd_id INT,
		prd_key VARCHAR(50),
		prd_nm VARCHAR(50),
		prd_cost INT,
        prd_line VARCHAR(50),
        prd_start_dt DATETIME,
        prd_end_dt DATETIME
	);
    
LOAD DATA LOCAL INFILE '/Users/akshaybisht/Desktop/Projects/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE dwarehouse_project_bronze.crm_prd_info
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


-- SELECT '------------------  Creating crm_sales_details';

DROP TABLE IF EXISTS dwarehouse_project_bronze.crm_sales_details;    
CREATE TABLE dwarehouse_project_bronze.crm_sales_details (
		sls_ord_num VARCHAR(50),
		sls_prd_key VARCHAR(50),
		sls_cust_id INT,
		sls_order_dt INT,
        sls_ship_dt INT,
		sls_due_dt INT,
        sls_sales INT,
        sls_quantity INT,
		sls_price INT
	);

LOAD DATA LOCAL INFILE '/Users/akshaybisht/Desktop/Projects/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE dwarehouse_project_bronze.crm_sales_details
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


-- SELECT '------------------------------------------';
-- SELECT '------  CREATE AND LOAD ERP SCHEMA  ------';
-- SELECT '------------------------------------------';

-- SELECT '----------------  Creating erp_local_a_101';

DROP TABLE IF EXISTS dwarehouse_project_bronze.erp_local_a_101;
CREATE TABLE dwarehouse_project_bronze.erp_local_a_101(
		cid VARCHAR(50),
        cntry VARCHAR(50)
	);

LOAD DATA LOCAL INFILE '/Users/akshaybisht/Desktop/Projects/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
INTO TABLE dwarehouse_project_bronze.erp_local_a_101
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


-- SELECT '-------------------  Creating erp_cust_a12';

DROP TABLE IF EXISTS dwarehouse_project_bronze.erp_cust_a12;
CREATE TABLE dwarehouse_project_bronze.erp_cust_a12(
		cid VARCHAR(50),
        bdate DATE,
        gen VARCHAR(50)
	);

LOAD DATA LOCAL INFILE '/Users/akshaybisht/Desktop/Projects/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE dwarehouse_project_bronze.erp_cust_a12
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;    


-- SELECT '-------------------  Creating erp_lpx_cat_g1v2';

DROP TABLE IF EXISTS dwarehouse_project_bronze.erp_px_cat_g1v2;    
CREATE TABLE dwarehouse_project_bronze.erp_px_cat_g1v2(
		id VARCHAR(50),
        cat VARCHAR(50),
        subcat VARCHAR(50),
        maintenance VARCHAR(50)
	);

LOAD DATA LOCAL INFILE '/Users/akshaybisht/Desktop/Projects/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE dwarehouse_project_bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;   


SELECT * FROM crm_prd_info;
