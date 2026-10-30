USE SupplyChain;
GO

-- 05_mart_facts: tablas de hechos con PK y FK hacia las dimensiones.

DROP TABLE IF EXISTS mart.fact_sales, mart.fact_procurement;
GO

-- ---------- fact_sales: una fila por pedido de venta ----------
CREATE TABLE mart.fact_sales (
    Order_ID                     VARCHAR(20)   NOT NULL,
    Customer_ID                  VARCHAR(20)   NOT NULL,
    Product_ID                   VARCHAR(20)   NOT NULL,
    Order_Date_Key               INT           NOT NULL,
    Ship_Scheduled_Date_Key      INT           NOT NULL,
    Ship_Actual_Date_Key         INT           NOT NULL,
    Order_Status                 VARCHAR(20)   NOT NULL,
    Shipping_Mode                VARCHAR(20)   NOT NULL,
    Shipping_Carrier             VARCHAR(20)   NOT NULL,
    Order_Quantity               INT           NOT NULL,
    Unit_Price                   DECIMAL(18,4) NOT NULL,
    Discount                     DECIMAL(9,4)  NOT NULL,
    Unit_Price_Effective         DECIMAL(18,6) NOT NULL,
    Order_Total                  DECIMAL(18,4) NOT NULL,
    VAT_Rate                     DECIMAL(9,4)  NOT NULL,
    VAT_Amount                   DECIMAL(18,6) NOT NULL,
    COGS                         DECIMAL(18,4) NOT NULL,
    Profit_Per_Order             DECIMAL(18,4) NOT NULL,
    CONSTRAINT PK_fact_sales PRIMARY KEY (Order_ID),
    CONSTRAINT FK_sales_customer  FOREIGN KEY (Customer_ID) REFERENCES mart.dim_customer (Customer_ID),
    CONSTRAINT FK_sales_product   FOREIGN KEY (Product_ID)  REFERENCES mart.dim_product (Product_ID),
    CONSTRAINT FK_sales_orderdate FOREIGN KEY (Order_Date_Key)          REFERENCES mart.dim_date (Date_Key),
    CONSTRAINT FK_sales_shipsched FOREIGN KEY (Ship_Scheduled_Date_Key) REFERENCES mart.dim_date (Date_Key),
    CONSTRAINT FK_sales_shipact   FOREIGN KEY (Ship_Actual_Date_Key)    REFERENCES mart.dim_date (Date_Key)
);

INSERT INTO mart.fact_sales
SELECT
    Order_ID, Customer_ID, Product_ID,
    YEAR(Order_Date)*10000 + MONTH(Order_Date)*100 + DAY(Order_Date),
    YEAR(Shipping_Date_Scheduled)*10000 + MONTH(Shipping_Date_Scheduled)*100 + DAY(Shipping_Date_Scheduled),
    YEAR(Shipping_Date_Actual)*10000 + MONTH(Shipping_Date_Actual)*100 + DAY(Shipping_Date_Actual),
    Order_Status, Shipping_Mode, Shipping_Carrier,
    Order_Quantity, Unit_Price, Discount, Unit_Price_Effective, Order_Total,
    VAT_Rate, VAT_Amount, COGS, Profit_Per_Order
FROM clean.sales_orders
WHERE flag_bad_cast = 0;

-- ---------- fact_procurement: una fila por orden de compra ----------
CREATE TABLE mart.fact_procurement (
    PO_ID                   VARCHAR(20)   NOT NULL,
    Supplier_ID             VARCHAR(20)   NOT NULL,
    Product_ID              VARCHAR(20)   NOT NULL,   -- viene de Raw_Material_ID
    Order_Date_Key          INT           NOT NULL,
    Delivery_Planned_Key    INT           NOT NULL,
    Delivery_Actual_Key     INT           NOT NULL,
    Order_Quantity          INT           NOT NULL,
    Unit_Cost               DECIMAL(18,4) NOT NULL,
    Total_Cost              DECIMAL(18,4) NOT NULL,
    CONSTRAINT PK_fact_procurement PRIMARY KEY (PO_ID),
    CONSTRAINT FK_proc_supplier  FOREIGN KEY (Supplier_ID) REFERENCES mart.dim_supplier (Supplier_ID),
    CONSTRAINT FK_proc_product   FOREIGN KEY (Product_ID)  REFERENCES mart.dim_product (Product_ID),
    CONSTRAINT FK_proc_orderdate FOREIGN KEY (Order_Date_Key)       REFERENCES mart.dim_date (Date_Key),
    CONSTRAINT FK_proc_planned   FOREIGN KEY (Delivery_Planned_Key) REFERENCES mart.dim_date (Date_Key),
    CONSTRAINT FK_proc_actual    FOREIGN KEY (Delivery_Actual_Key)  REFERENCES mart.dim_date (Date_Key)
);

INSERT INTO mart.fact_procurement
SELECT
    PO_ID, Supplier_ID, Raw_Material_ID,
    YEAR(Order_Date)*10000 + MONTH(Order_Date)*100 + DAY(Order_Date),
    YEAR(Delivery_Date_Planned)*10000 + MONTH(Delivery_Date_Planned)*100 + DAY(Delivery_Date_Planned),
    YEAR(Delivery_Date_Actual)*10000 + MONTH(Delivery_Date_Actual)*100 + DAY(Delivery_Date_Actual),
    Order_Quantity, Unit_Cost, Total_Cost
FROM clean.procurement_orders
WHERE flag_bad_cast = 0;
GO

-- Verificacion: filas y totales iguales a clean
SELECT 'fact_sales' AS tabla, COUNT(*) AS filas, SUM(Order_Total) AS total FROM mart.fact_sales
UNION ALL SELECT 'clean.sales_orders', COUNT(*), SUM(Order_Total) FROM clean.sales_orders
UNION ALL SELECT 'fact_procurement', COUNT(*), SUM(Total_Cost) FROM mart.fact_procurement
UNION ALL SELECT 'clean.procurement_orders', COUNT(*), SUM(Total_Cost) FROM clean.procurement_orders;