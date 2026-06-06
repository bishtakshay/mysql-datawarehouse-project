DROP SCHEMA IF EXISTS dwarehouse_project_gold;
CREATE SCHEMA dwarehouse_project_gold;

-- '------------------------------------------';
-- '-  CREATE AND LOAD DIM_CUSTOMERS SCHEMA  -';
-- '------------------------------------------';

CREATE TABLE dwarehouse_project_gold.dim_customers (
	customer_key INT,
	customer_id INT,
	customer_number VARCHAR(50),
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	gender VARCHAR(20),
	marital_status VARCHAR(20),
	birth_date DATE,
	country VARCHAR(50),
	create_date DATE
	);

TRUNCATE TABLE dwarehouse_project_gold.dim_customers;
USE dwarehouse_project_silver;
INSERT INTO  dwarehouse_project_gold.dim_customers(
	customer_key,
	customer_id,
	customer_number,
	first_name,
	last_name,
	gender,
	marital_status,
	birth_date,
	country,
	create_date
	)
	SELECT ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
		   ci.cst_id AS customer_id,
		   ci.cst_key AS customer_number,
		   ci.cst_firstname AS first_name,
		   ci.cst_lastname AS last_name,
		   CASE WHEN ci.cst_gndr != "N/A" THEN ci.cst_gndr 
				ELSE ca.gen
				END AS gender,            -- Assuming crm as master data source
		   ci.cst_material_status AS marital_status,
		   ca.bdate AS birth_date,
		   cc.cntry AS country,
		   ci.cst_create_date AS create_date
		FROM crm_cust_info AS ci
			LEFT JOIN erp_local_a_101 AS cc 
				ON ci.cst_key = cc.cid
			LEFT JOIN erp_cust_a12 AS ca
				ON ci.cst_key = ca.cid;
                

-- '------------------------------------------';
-- '-  CREATE AND LOAD DIM_PRODUCTS SCHEMA  --';
-- '------------------------------------------';

CREATE TABLE dwarehouse_project_gold.dim_products (
		product_key INT,
        product_id INT,
		product_number VARCHAR(50),
		product_name VARCHAR(100),
		category_id VARCHAR(50),
		category VARCHAR(50),
		subcategory VARCHAR(50),
		maintenance VARCHAR(20),
		cost INT,
		product_line VARCHAR(50),
		start_date DATE
	);

TRUNCATE TABLE dwarehouse_project_gold.dim_products;
USE dwarehouse_project_silver;
INSERT INTO dwarehouse_project_gold.dim_products(
	product_key,
	product_id,
	product_number,
	product_name,
	category_id,
	category,
	subcategory,
	maintenance,
	cost,
	product_line,
	start_date)
	SELECT
		ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
		pn.prd_id AS product_id,
		pn.prd_key AS product_number,
		pn.prd_nm AS product_name,
		pn.cat_id AS category_id,
		pc.cat AS category,
		pc.subcat AS subcategory,
		pc.maintenance,
		pn.prd_cost AS cost,
		pn.prd_line AS product_line,
		pn.prd_start_dt AS start_date
		FROM crm_prd_info AS pn
		LEFT JOIN erp_px_cat_g1v2 AS pc
			ON pn.cat_id = pc.id
		WHERE pn.prd_end_dt IS NULL;


-- '------------------------------------------';
-- '--  CREATE AND LOAD FACT_SALES SCHEMA  ---';
-- '------------------------------------------';

CREATE TABLE dwarehouse_project_gold.fact_sales(
		order_number VARCHAR(50),
		product_key INT,
		customer_id INT,
		order_date DATE, 
		shipping_date DATE,
		due_date DATE,
		sales_amount INT,
		quantity INT,
		price INT);
  
TRUNCATE TABLE dwarehouse_project_gold.fact_sales;
USE dwarehouse_project_silver;  
INSERT INTO dwarehouse_project_gold.fact_sales(
	order_number,
	product_key,
	customer_id,
	order_date, 
	shipping_date,
	due_date,
	sales_amount,
	quantity,
	price)
	SELECT 
		sd.sls_ord_num AS order_number,
		pd.product_key,
		cd.customer_id,
		sd.sls_order_dt AS order_date, 
		sd.sls_ship_dt AS shipping_date,
		sd.sls_due_dt AS due_date,
		sd.sls_sales AS sales_amount,
		sd.sls_quantity AS quantity,
		sd.sls_price AS price 
		FROM crm_sales_details AS sd
		LEFT JOIN dwarehouse_project_gold.dim_customers AS cd
			ON sd.sls_cust_id = cd.customer_id      
		LEFT JOIN dwarehouse_project_gold.dim_products AS pd
			ON sd.sls_prd_key = pd.product_number;