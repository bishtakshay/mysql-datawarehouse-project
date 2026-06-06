# Data Catalog for Gold Layer

## Overview
The Gold Layer (`dwarehouse_project_gold`) is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and a **fact table** for specific business metrics. Data is sourced and transformed from the Silver layer (`dwarehouse_project_silver`), combining CRM and ERP source systems.

---

### 1. **dwarehouse_project_gold.dim_customers**
- **Purpose:** Stores customer details enriched with demographic and geographic data, sourced by joining CRM customer info (`crm_cust_info`) with ERP location (`erp_local_a_101`) and ERP customer attribute (`erp_cust_a12`) tables. Gender is resolved using CRM as the master data source, falling back to ERP when CRM value is 'N/A'.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| customer_key     | INT           | Surrogate key uniquely identifying each customer record, generated using ROW_NUMBER() ordered by customer ID. |
| customer_id      | INT           | Unique numerical identifier assigned to each customer. Sourced from `crm_cust_info.cst_id`.   |
| customer_number  | VARCHAR(50)   | Alphanumeric identifier representing the customer, used for tracking and referencing. Sourced from `crm_cust_info.cst_key`. |
| first_name       | VARCHAR(50)   | The customer's first name, as recorded in the CRM system. Sourced from `crm_cust_info.cst_firstname`. |
| last_name        | VARCHAR(50)   | The customer's last name or family name. Sourced from `crm_cust_info.cst_lastname`.           |
| gender           | VARCHAR(20)   | The gender of the customer (e.g., 'Male', 'Female', 'N/A'). CRM is the master source; falls back to ERP (`erp_cust_a12.gen`) when CRM value is 'N/A'. |
| marital_status   | VARCHAR(20)   | The marital status of the customer (e.g., 'Married', 'Single'). Sourced from `crm_cust_info.cst_material_status`. |
| birth_date       | DATE          | The date of birth of the customer, formatted as YYYY-MM-DD. Sourced from `erp_cust_a12.bdate`. |
| country          | VARCHAR(50)   | The country of residence for the customer (e.g., 'Australia'). Sourced from `erp_local_a_101.cntry`. |
| create_date      | DATE          | The date when the customer record was created in the system. Sourced from `crm_cust_info.cst_create_date`. |

---

### 2. **dwarehouse_project_gold.dim_products**
- **Purpose:** Provides information about products and their attributes, sourced by joining CRM product info (`crm_prd_info`) with ERP product category (`erp_px_cat_g1v2`). Only active products are included — records with a non-null `prd_end_dt` are excluded.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| product_key      | INT           | Surrogate key uniquely identifying each product record, generated using ROW_NUMBER() ordered by start date and product key. |
| product_id       | INT           | A unique identifier assigned to the product for internal tracking and referencing. Sourced from `crm_prd_info.prd_id`. |
| product_number   | VARCHAR(50)   | A structured alphanumeric code representing the product, often used for categorization or inventory. Sourced from `crm_prd_info.prd_key`. |
| product_name     | VARCHAR(100)  | Descriptive name of the product, including key details such as type, color, and size. Sourced from `crm_prd_info.prd_nm`. |
| category_id      | VARCHAR(50)   | A unique identifier for the product's category, linking to its high-level classification. Sourced from `crm_prd_info.cat_id`. |
| category         | VARCHAR(50)   | The broader classification of the product (e.g., 'Bikes', 'Components'). Sourced from `erp_px_cat_g1v2.cat`. |
| subcategory      | VARCHAR(50)   | A more detailed classification of the product within the category, such as product type. Sourced from `erp_px_cat_g1v2.subcat`. |
| maintenance      | VARCHAR(20)   | Indicates whether the product requires maintenance (e.g., 'Yes', 'No'). Sourced from `erp_px_cat_g1v2.maintenance`. |
| cost             | INT           | The cost or base price of the product, measured in monetary units. Sourced from `crm_prd_info.prd_cost`. |
| product_line     | VARCHAR(50)   | The specific product line or series to which the product belongs (e.g., 'Road', 'Mountain'). Sourced from `crm_prd_info.prd_line`. |
| start_date       | DATE          | The date when the product became available for sale or use. Sourced from `crm_prd_info.prd_start_dt`. |

---

### 3. **dwarehouse_project_gold.fact_sales**
- **Purpose:** Stores transactional sales data for analytical purposes. Records are sourced from CRM sales details (`crm_sales_details`) and resolved against `dim_customers` and `dim_products` via left joins. Note: this table links to customers via `customer_id` (natural key) rather than `customer_key` (surrogate key).
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| order_number    | VARCHAR(50)   | A unique alphanumeric identifier for each sales order (e.g., 'SO54496'). Sourced from `crm_sales_details.sls_ord_num`. |
| product_key     | INT           | Surrogate key linking the order to the `dim_products` dimension table. Resolved by matching `crm_sales_details.sls_prd_key` to `dim_products.product_number`. |
| customer_id     | INT           | Natural key linking the order to the `dim_customers` dimension table. Sourced from `crm_sales_details.sls_cust_id`, matched to `dim_customers.customer_id`. |
| order_date      | DATE          | The date when the order was placed. Sourced from `crm_sales_details.sls_order_dt`.           |
| shipping_date   | DATE          | The date when the order was shipped to the customer. Sourced from `crm_sales_details.sls_ship_dt`. |
| due_date        | DATE          | The date when the order payment was due. Sourced from `crm_sales_details.sls_due_dt`.        |
| sales_amount    | INT           | The total monetary value of the sale for the line item, in whole currency units. Sourced from `crm_sales_details.sls_sales`. |
| quantity        | INT           | The number of units of the product ordered for the line item. Sourced from `crm_sales_details.sls_quantity`. |
| price           | INT           | The price per unit of the product for the line item, in whole currency units. Sourced from `crm_sales_details.sls_price`. |
