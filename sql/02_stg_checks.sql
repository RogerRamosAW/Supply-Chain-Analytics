USE SupplyChain;
GO

-- 1) Conteos: cada tabla contra lo esperado
SELECT 
'product_master' AS tabla,
COUNT(*) AS filas,
200 AS esperado FROM stg.product_master
UNION ALL SELECT 'supplier_master',     
			COUNT(*), 100   FROM stg.supplier_master
UNION ALL SELECT 'customer_master',
			COUNT(*), 500   FROM stg.customer_master
UNION ALL SELECT 'sales_orders',
			COUNT(*), 20000 FROM stg.sales_orders
UNION ALL SELECT 'procurement_orders',  
			COUNT(*), 2000  FROM stg.procurement_orders;

-- 2) El encabezado no se coló como dato (esperado: 0)
SELECT 
COUNT(*) AS encabezado_como_dato 
FROM stg.sales_orders
WHERE Order_ID = 'Order_ID';

-- 3) Claves huérfanas (esperado: 0 en las tres)
SELECT 
COUNT(*) AS ventas_sin_cliente
FROM stg.sales_orders s
LEFT JOIN stg.customer_master c 
ON c.Customer_ID = s.Customer_ID
WHERE c.Customer_ID IS NULL;

SELECT COUNT(*) AS ventas_sin_producto
FROM stg.sales_orders s
LEFT JOIN stg.product_master p ON p.Product_ID = s.Product_ID
WHERE p.Product_ID IS NULL;

SELECT COUNT(*) AS compras_sin_proveedor
FROM stg.procurement_orders o
LEFT JOIN stg.supplier_master s ON s.Supplier_ID = o.Supplier_ID
WHERE s.Supplier_ID IS NULL;

-- 4) ¿Compras y ventas se conectan por producto? (esperado: 0 sin match)
SELECT COUNT(*) AS compras_sin_producto
FROM stg.procurement_orders o
LEFT JOIN stg.product_master p 
ON p.Product_ID = o.Raw_Material_ID
WHERE p.Product_ID IS NULL;

-- 5) IDs duplicados (esperado: sin filas)
SELECT 
Order_ID, 
COUNT(*) AS veces 
FROM stg.sales_orders 
GROUP BY Order_ID 
HAVING COUNT(*) > 1;

-- 5) Restos de carácter de fin de línea en la última columna: tiene que dar 0
SELECT 'sales' AS tabla, COUNT(*) AS con_CR FROM stg.sales_orders WHERE Profit_Per_Order LIKE '%' + CHAR(13) + '%'
UNION ALL SELECT 'procurement', COUNT(*) FROM stg.procurement_orders WHERE Total_Cost LIKE '%' + CHAR(13) + '%';	