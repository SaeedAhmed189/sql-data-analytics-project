/*
Create Database and Schemas
Script Purpose: This script creates a new database named 'DataWarehouseAnalytics' and handles NULL values in CSV imports.
WARNING: Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas
CREATE SCHEMA gold;
GO

-- Create Tables
-- Note: I have explicitly added 'NULL' to date columns to ensure they accept missing values.

CREATE TABLE gold.dim_customers(
    customer_key int,
    customer_id int,
    customer_number nvarchar(50),
    first_name nvarchar(50),
    last_name nvarchar(50),
    country nvarchar(50),
    marital_status nvarchar(50),
    gender nvarchar(50),
    birthdate date NULL, -- Allow NULLs here
    create_date date NULL
);
GO

CREATE TABLE gold.dim_products(
    product_key int,
    product_id int,
    product_number nvarchar(50),
    product_name nvarchar(50),
    category_id nvarchar(50),
    category nvarchar(50),
    subcategory nvarchar(50),
    maintenance nvarchar(50),
    cost int,
    product_line nvarchar(50),
    start_date date NULL
);
GO

CREATE TABLE gold.fact_sales(
    order_number nvarchar(50),
    product_key int,
    customer_key int,
    order_date date NULL, -- Allow NULLs here
    shipping_date date NULL,
    due_date date NULL,
    sales_amount int,
    quantity tinyint,
    price int
);
GO

-- Bulk Insert Operations
-- key change: Added 'KEEPNULLS' to handle empty CSV fields as NULLs

TRUNCATE TABLE gold.dim_customers;
GO
BULK INSERT gold.dim_customers
FROM 'E:\Users\Saeed Baloch\sql-data-analytics-project\datasets\dim_customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK,
    KEEPNULLS -- Prevents "Conversion failed" on empty date fields
);
GO

TRUNCATE TABLE gold.dim_products;
GO
BULK INSERT gold.dim_products
FROM 'E:\Users\Saeed Baloch\sql-data-analytics-project\datasets\dim_products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK,
    KEEPNULLS
);
GO

TRUNCATE TABLE gold.fact_sales;
GO
BULK INSERT gold.fact_sales
FROM 'E:\Users\Saeed Baloch\sql-data-analytics-project\datasets\fact_sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK,
    KEEPNULLS -- Critical for order_date nulls
);
GO