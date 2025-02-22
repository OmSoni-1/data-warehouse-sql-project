# Gold Layer Data Catalog

## Overview
The Gold Layer represents business-level structured data, designed to facilitate analytical and reporting needs. It comprises **dimension tables** and **fact tables** that capture key business metrics.

---

### 1. **gold.dim_customers**
- **Purpose:** Maintains customer information enriched with demographic and geographical attributes.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| customer_key     | INT           | A surrogate key that uniquely identifies each customer entry in the dimension table.          |
| customer_id      | INT           | A unique numeric identifier assigned to every customer.                                       |
| customer_number  | NVARCHAR(50)  | An alphanumeric code used to track and reference the customer.                               |
| first_name       | NVARCHAR(50)  | The recorded first name of the customer.                                                     |
| last_name        | NVARCHAR(50)  | The surname or family name of the customer.                                                  |
| country          | NVARCHAR(50)  | The country of residence of the customer (e.g., 'Australia').                               |
| marital_status   | NVARCHAR(50)  | Indicates the marital status of the customer (e.g., 'Married', 'Single').                   |
| gender           | NVARCHAR(50)  | Specifies the gender of the customer (e.g., 'Male', 'Female', 'n/a').                       |
| birthdate        | DATE          | The customer's date of birth, stored in YYYY-MM-DD format (e.g., 1971-10-06).                |
| create_date      | DATE          | The timestamp marking when the customer record was initially created in the system.          |

---

### 2. **gold.dim_products**
- **Purpose:** Contains details about products and their characteristics.
- **Columns:**

| Column Name         | Data Type     | Description                                                                                   |
|---------------------|---------------|-----------------------------------------------------------------------------------------------|
| product_key         | INT           | A surrogate key uniquely identifying each product entry within the dimension table.           |
| product_id          | INT           | A distinct numeric identifier assigned to each product for internal tracking.                 |
| product_number      | NVARCHAR(50)  | A structured alphanumeric code used for product categorization and inventory management.      |
| product_name        | NVARCHAR(50)  | A descriptive title of the product, including key details such as type, color, or size.      |
| category_id         | NVARCHAR(50)  | A unique identifier linking the product to its respective category.                          |
| category            | NVARCHAR(50)  | The broad classification of the product (e.g., Bikes, Components) to group similar items.    |
| subcategory         | NVARCHAR(50)  | A more specific classification of the product within its category.                           |
| maintenance_required| NVARCHAR(50)  | Specifies whether the product requires maintenance (e.g., 'Yes', 'No').                      |
| cost                | INT           | The product’s cost or base price, measured in monetary units.                                |
| product_line        | NVARCHAR(50)  | The specific series or collection to which the product belongs (e.g., Road, Mountain).      |
| start_date          | DATE          | The date when the product became available for purchase or use.                              |

---

### 3. **gold.fact_sales**
- **Purpose:** Captures transactional sales data for analytical evaluation.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| order_number    | NVARCHAR(50)  | A unique alphanumeric identifier assigned to each sales order (e.g., 'SO54496').              |
| product_key     | INT           | Surrogate key linking the order to the product dimension table.                               |
| customer_key    | INT           | Surrogate key linking the order to the customer dimension table.                              |
| order_date      | DATE          | The date on which the order was placed.                                                      |
| shipping_date   | DATE          | The date when the order was dispatched to the customer.                                      |
| due_date        | DATE          | The deadline for order payment.                                                              |
| sales_amount    | INT           | The total monetary value of the sale for the specific line item, recorded in whole units.    |
| quantity        | INT           | The number of units purchased for the given line item.                                      |
| price           | INT           | The price per unit of the product, stored in whole currency units.                          |
