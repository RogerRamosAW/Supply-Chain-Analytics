USE SupplyChain;
GO

-- 04_mart_dims: dimensiones del modelo estrella, con PK.
-- Se cargan desde clean, solo filas con flag_bad_cast = 0.

DROP TABLE IF EXISTS mart.fact_sales, mart.fact_procurement;   -- primero los hechos (tienen FK)
DROP TABLE IF EXISTS mart.dim_product, mart.dim_supplier, mart.dim_customer, mart.dim_date;
GO

-- ---------- dim_product ----------
CREATE TABLE mart.dim_product (
    Product_ID           VARCHAR(20)   NOT NULL,
    SKU                  VARCHAR(20)   NOT NULL,
    Product_Name         VARCHAR(100)  NOT NULL,
    Category             VARCHAR(50)   NOT NULL,
    Subcategory          VARCHAR(10)   NOT NULL,
    Unit                 VARCHAR(10)   NOT NULL,
    Unit_Cost            DECIMAL(18,4) NOT NULL,
    Standard_Price       DECIMAL(18,4) NOT NULL,
    Launch_Date          DATE          NOT NULL,
    Discontinuation_Date DATE          NULL,
    CONSTRAINT PK_dim_product PRIMARY KEY (Product_ID)
);

INSERT INTO mart.dim_product
SELECT Product_ID, SKU, Product_Name, Category, Subcategory, Unit,
       Unit_Cost, Standard_Price, Launch_Date, Discontinuation_Date
FROM clean.product_master
WHERE flag_bad_cast = 0;

-- ---------- dim_supplier ----------
CREATE TABLE mart.dim_supplier (
    Supplier_ID             VARCHAR(20)  NOT NULL,
    Supplier_Name           VARCHAR(100) NOT NULL,
    Country                 VARCHAR(50)  NOT NULL,
    Region                  VARCHAR(20)  NOT NULL,
    On_Time_Delivery_Rate   DECIMAL(9,4) NOT NULL,
    Certification_Level     VARCHAR(30)  NOT NULL,
    Preferred_Supplier_Flag TINYINT      NOT NULL,
    CONSTRAINT PK_dim_supplier PRIMARY KEY (Supplier_ID)
);

INSERT INTO mart.dim_supplier
SELECT Supplier_ID, Supplier_Name, Country, Region, On_Time_Delivery_Rate,
       Certification_Level, Preferred_Supplier_Flag
FROM clean.supplier_master
WHERE flag_bad_cast = 0;

-- ---------- dim_customer ----------
CREATE TABLE mart.dim_customer (
    Customer_ID    VARCHAR(20)  NOT NULL,
    Customer_Name  VARCHAR(100) NOT NULL,
    Industry       VARCHAR(50)  NOT NULL,
    Market_Segment VARCHAR(10)  NOT NULL,
    Country        VARCHAR(50)  NOT NULL,
    City           VARCHAR(50)  NOT NULL,
    Latitude       DECIMAL(9,4) NOT NULL,
    Longitude      DECIMAL(9,4) NOT NULL,
    CONSTRAINT PK_dim_customer PRIMARY KEY (Customer_ID)
);

INSERT INTO mart.dim_customer
SELECT Customer_ID, Customer_Name, Industry, Market_Segment, Country, City, Latitude, Longitude
FROM clean.customer_master
WHERE flag_bad_cast = 0;

-- ---------- dim_date: un calendario, una fila por dia (2021-2024) ----------
CREATE TABLE mart.dim_date (
    Date_Key    INT         NOT NULL,   -- formato 20240131
    [Date]      DATE        NOT NULL,
    [Year]      SMALLINT    NOT NULL,
    [Quarter]   TINYINT     NOT NULL,
    [Month]     TINYINT     NOT NULL,
    Month_Name  VARCHAR(10) NOT NULL,
    [Day]       TINYINT     NOT NULL,
    Day_Name    VARCHAR(10) NOT NULL,
    Is_Weekend  BIT         NOT NULL,
    CONSTRAINT PK_dim_date PRIMARY KEY (Date_Key)
);

WITH d AS (
    SELECT CAST('2021-01-01' AS DATE) AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt) FROM d WHERE dt < '2024-12-31'
)
INSERT INTO mart.dim_date
SELECT
    YEAR(dt)*10000 + MONTH(dt)*100 + DAY(dt),
    dt, YEAR(dt), DATEPART(QUARTER, dt), MONTH(dt),
    CHOOSE(MONTH(dt),'January','February','March','April','May','June','July',
                     'August','September','October','November','December'),
    DAY(dt),
    CHOOSE(DATEDIFF(DAY,'19000101',dt) % 7 + 1,'Monday','Tuesday','Wednesday',
                     'Thursday','Friday','Saturday','Sunday'),
    CASE WHEN DATEDIFF(DAY,'19000101',dt) % 7 IN (5,6) THEN 1 ELSE 0 END
FROM d
OPTION (MAXRECURSION 0);
GO

-- Verificacion: 200 / 100 / 500 / 1461 filas
SELECT 'dim_product' AS tabla, COUNT(*) AS filas FROM mart.dim_product
UNION ALL SELECT 'dim_supplier', COUNT(*) FROM mart.dim_supplier
UNION ALL SELECT 'dim_customer', COUNT(*) FROM mart.dim_customer
UNION ALL SELECT 'dim_date', COUNT(*) FROM mart.dim_date;