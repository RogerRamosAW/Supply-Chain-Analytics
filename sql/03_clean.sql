USE SupplyChain;
GO

-- 03_clean: convierte stg (texto) a tipos reales. No borra filas.
-- Cada tabla lleva flag_bad_cast = 1 si algun valor no se pudo convertir.

DROP TABLE IF EXISTS clean.product_master, clean.supplier_master, clean.customer_master,
                     clean.sales_orders, clean.procurement_orders;
GO

SELECT
    Product_ID, SKU, Product_Name, Category, Subcategory, Unit,
    TRY_CAST(Unit_Cost AS DECIMAL(18,4))        AS Unit_Cost,
    TRY_CAST(Standard_Price AS DECIMAL(18,4))   AS Standard_Price,
    TRY_CAST(Launch_Date AS DATE)               AS Launch_Date,
    TRY_CAST(NULLIF(Discontinuation_Date,'') AS DATE) AS Discontinuation_Date,
    CASE WHEN TRY_CAST(Unit_Cost AS DECIMAL(18,4)) IS NULL
           OR TRY_CAST(Standard_Price AS DECIMAL(18,4)) IS NULL
           OR TRY_CAST(Launch_Date AS DATE) IS NULL THEN 1 ELSE 0 END AS flag_bad_cast
INTO clean.product_master
FROM stg.product_master;

SELECT
    Supplier_ID, Supplier_Name, Country, Region,
    TRY_CAST(On_Time_Delivery_Rate AS DECIMAL(9,4)) AS On_Time_Delivery_Rate,
    Certification_Level,
    TRY_CAST(Preferred_Supplier_Flag AS TINYINT)    AS Preferred_Supplier_Flag,
    CASE WHEN TRY_CAST(On_Time_Delivery_Rate AS DECIMAL(9,4)) IS NULL
           OR TRY_CAST(Preferred_Supplier_Flag AS TINYINT) IS NULL THEN 1 ELSE 0 END AS flag_bad_cast
INTO clean.supplier_master
FROM stg.supplier_master;

SELECT
    Customer_ID, Customer_Name, Industry, Market_Segment, Country, City,
    TRY_CAST(Latitude AS DECIMAL(9,4))  AS Latitude,
    TRY_CAST(Longitude AS DECIMAL(9,4)) AS Longitude,
    CASE WHEN TRY_CAST(Latitude AS DECIMAL(9,4)) IS NULL
           OR TRY_CAST(Longitude AS DECIMAL(9,4)) IS NULL THEN 1 ELSE 0 END AS flag_bad_cast
INTO clean.customer_master
FROM stg.customer_master;

-- OJO: Late_Delivery_Risk_Flag se deriva de las fechas de envio (fuga de datos).
-- No usarla como variable explicativa de entregas tarde.
SELECT
    Order_ID, Customer_ID, Product_ID,
    TRY_CAST(Order_Date AS DATE)                 AS Order_Date,
    Order_Status,
    TRY_CAST(Order_Quantity AS INT)              AS Order_Quantity,
    TRY_CAST(Unit_Price AS DECIMAL(18,4))        AS Unit_Price,
    TRY_CAST(Discount AS DECIMAL(9,4))           AS Discount,
    Shipping_Mode, Shipping_Carrier,
    TRY_CAST(Shipping_Date_Scheduled AS DATE)    AS Shipping_Date_Scheduled,
    TRY_CAST(Shipping_Date_Actual AS DATE)       AS Shipping_Date_Actual,
    Delivery_Status,
    TRY_CAST(Late_Delivery_Risk_Flag AS TINYINT) AS Late_Delivery_Risk_Flag,
    TRY_CAST(VAT_Rate AS DECIMAL(9,4))           AS VAT_Rate,
    TRY_CAST(COGS AS DECIMAL(18,4))              AS COGS,
    TRY_CAST(Unit_Price_Effective AS DECIMAL(18,6)) AS Unit_Price_Effective,
    TRY_CAST(Order_Total AS DECIMAL(18,4))       AS Order_Total,
    TRY_CAST(VAT_Amount AS DECIMAL(18,6))        AS VAT_Amount,
    TRY_CAST(Profit_Per_Order AS DECIMAL(18,4))  AS Profit_Per_Order,
    CASE WHEN TRY_CAST(Order_Date AS DATE) IS NULL
           OR TRY_CAST(Order_Quantity AS INT) IS NULL
           OR TRY_CAST(Unit_Price AS DECIMAL(18,4)) IS NULL
           OR TRY_CAST(Discount AS DECIMAL(9,4)) IS NULL
           OR TRY_CAST(Shipping_Date_Scheduled AS DATE) IS NULL
           OR TRY_CAST(Shipping_Date_Actual AS DATE) IS NULL
           OR TRY_CAST(Late_Delivery_Risk_Flag AS TINYINT) IS NULL
           OR TRY_CAST(VAT_Rate AS DECIMAL(9,4)) IS NULL
           OR TRY_CAST(COGS AS DECIMAL(18,4)) IS NULL
           OR TRY_CAST(Order_Total AS DECIMAL(18,4)) IS NULL
           OR TRY_CAST(VAT_Amount AS DECIMAL(18,6)) IS NULL
           OR TRY_CAST(Profit_Per_Order AS DECIMAL(18,4)) IS NULL THEN 1 ELSE 0 END AS flag_bad_cast
INTO clean.sales_orders
FROM stg.sales_orders;

SELECT
    PO_ID, Supplier_ID, Raw_Material_ID,
    TRY_CAST(Order_Date AS DATE)             AS Order_Date,
    TRY_CAST(Order_Quantity AS INT)          AS Order_Quantity,
    TRY_CAST(Unit_Cost AS DECIMAL(18,4))     AS Unit_Cost,
    TRY_CAST(Delivery_Date_Planned AS DATE)  AS Delivery_Date_Planned,
    TRY_CAST(Delivery_Date_Actual AS DATE)   AS Delivery_Date_Actual,
    TRY_CAST(Total_Cost AS DECIMAL(18,4))    AS Total_Cost,
    CASE WHEN TRY_CAST(Order_Date AS DATE) IS NULL
           OR TRY_CAST(Order_Quantity AS INT) IS NULL
           OR TRY_CAST(Unit_Cost AS DECIMAL(18,4)) IS NULL
           OR TRY_CAST(Delivery_Date_Planned AS DATE) IS NULL
           OR TRY_CAST(Delivery_Date_Actual AS DATE) IS NULL
           OR TRY_CAST(Total_Cost AS DECIMAL(18,4)) IS NULL THEN 1 ELSE 0 END AS flag_bad_cast
INTO clean.procurement_orders
FROM stg.procurement_orders;
GO

-- Verificacion: filas = las de stg (200/100/500/20000/2000) y flags = 0
SELECT 'product_master' AS tabla, COUNT(*) AS filas, SUM(flag_bad_cast) AS malas FROM clean.product_master
UNION ALL SELECT 'supplier_master', COUNT(*), SUM(flag_bad_cast) FROM clean.supplier_master
UNION ALL SELECT 'customer_master', COUNT(*), SUM(flag_bad_cast) FROM clean.customer_master
UNION ALL SELECT 'sales_orders', COUNT(*), SUM(flag_bad_cast) FROM clean.sales_orders
UNION ALL SELECT 'procurement_orders', COUNT(*), SUM(flag_bad_cast) FROM clean.procurement_orders;