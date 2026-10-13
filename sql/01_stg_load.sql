USE SupplyChain;
GO
/*
01_stg_load.sql: carga cruda de los 5 CSV al esquema stg (todo NVARCHAR, sin transformar).
Requisitos: base SupplyChain y esquemas creados (00_create_schemas.sql).
            CSV copiados a C:\data\ (ruta local de desarrollo)
Re-ejecutable: cada bloque borra y recrea su tabla.
Formato de los CSV: separador coma, fin de línea LF, sin comillas.
*/

-- ===== product_master (esperado: 200 filas) =====
DROP TABLE IF EXISTS stg.product_master;
CREATE TABLE stg.product_master (
    Product_ID NVARCHAR(255), SKU NVARCHAR(255), Product_Name NVARCHAR(255),
    Category NVARCHAR(255), Subcategory NVARCHAR(255), Unit NVARCHAR(255),
    Unit_Cost NVARCHAR(255), Standard_Price NVARCHAR(255),
    Launch_Date NVARCHAR(255), Discontinuation_Date NVARCHAR(255)
);
BULK INSERT stg.product_master FROM 'C:\data\product_master.csv'
WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
GO

-- ===== supplier_master (esperado: 100 filas) =====
DROP TABLE IF EXISTS stg.supplier_master;
CREATE TABLE stg.supplier_master (
    Supplier_ID NVARCHAR(255), Supplier_Name NVARCHAR(255), Country NVARCHAR(255),
    Region NVARCHAR(255), On_Time_Delivery_Rate NVARCHAR(255),
    Certification_Level NVARCHAR(255), Preferred_Supplier_Flag NVARCHAR(255)
);
BULK INSERT stg.supplier_master FROM 'C:\data\supplier_master.csv'
WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
GO

-- ===== customer_master (esperado: 500 filas) =====
DROP TABLE IF EXISTS stg.customer_master;
CREATE TABLE stg.customer_master (
    Customer_ID NVARCHAR(255), Customer_Name NVARCHAR(255), Industry NVARCHAR(255),
    Market_Segment NVARCHAR(255), Country NVARCHAR(255), City NVARCHAR(255),
    Latitude NVARCHAR(255), Longitude NVARCHAR(255)
);
BULK INSERT stg.customer_master FROM 'C:\data\customer_master.csv'
WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
GO

-- ===== sales_orders (esperado: 20000 filas) =====
-- FIRSTROW=2 porque este CSV tiene una línea en blanco antes del encabezado
DROP TABLE IF EXISTS stg.sales_orders;
CREATE TABLE stg.sales_orders (
    Order_ID NVARCHAR(255), Customer_ID NVARCHAR(255), Product_ID NVARCHAR(255),
    Order_Date NVARCHAR(255), Order_Status NVARCHAR(255), Order_Quantity NVARCHAR(255),
    Unit_Price NVARCHAR(255), Discount NVARCHAR(255), Shipping_Mode NVARCHAR(255),
    Shipping_Carrier NVARCHAR(255), Shipping_Date_Scheduled NVARCHAR(255),
    Shipping_Date_Actual NVARCHAR(255), Delivery_Status NVARCHAR(255),
    Late_Delivery_Risk_Flag NVARCHAR(255), VAT_Rate NVARCHAR(255), COGS NVARCHAR(255),
    Unit_Price_Effective NVARCHAR(255), Order_Total NVARCHAR(255),
    VAT_Amount NVARCHAR(255), Profit_Per_Order NVARCHAR(255)
);
BULK INSERT stg.sales_orders FROM 'C:\data\sales_orders.csv'
WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
GO

-- ===== procurement_orders (esperado: 2000 filas) =====
DROP TABLE IF EXISTS stg.procurement_orders;
CREATE TABLE stg.procurement_orders (
    PO_ID NVARCHAR(255), Supplier_ID NVARCHAR(255), Raw_Material_ID NVARCHAR(255),
    Order_Date NVARCHAR(255), Order_Quantity NVARCHAR(255), Unit_Cost NVARCHAR(255),
    Delivery_Date_Planned NVARCHAR(255), Delivery_Date_Actual NVARCHAR(255),
    Total_Cost NVARCHAR(255)
);
BULK INSERT stg.procurement_orders FROM 'C:\data\procurement_orders.csv'
WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
GO