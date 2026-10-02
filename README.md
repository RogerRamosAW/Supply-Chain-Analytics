# 🚚 Supply Chain End-to-End Analytics

## 📌 Descripción del Proyecto
Este proyecto analiza un dataset de cadena de suministro que emula una operación real de extremo a extremo, abarcando **adquisiciones, producción y ventas**.
El objetivo es identificar ineficiencias en entregas, evaluar el desempeño de proveedores, analizar rentabilidad y construir dashboards que apoyen la toma de decisiones.

## 🎯 Problema de Negocio
Las operaciones de supply chain enfrentan desafíos como:
- Entregas tardías que afectan la satisfacción del cliente.
- Proveedores con bajo desempeño.
- Falta de visibilidad en la rentabilidad por producto, cliente o región.
- Dificultad para pronosticar la demanda.

**Pregunta central:** ¿Cómo podemos mejorar la eficiencia operativa y la rentabilidad utilizando los datos históricos de ventas, compras y proveedores?

## 📊 Dataset
- **Fuente:** [Kaggle - Supply Chain Datasets](https://www.kaggle.com/datasets/ayodejiibrahimlateef/supply-chain-datasets)
- **Tablas principales:**
  - `Product Master` – 200 productos (SKU, nombre, categoría, costo unitario, precio estándar, fechas de lanzamiento/descontinuación).
  - `Supplier Master` – 100 proveedores (país, región, tasa de entrega a tiempo, certificación, indicador preferred).
  - `Customer Master` – 500 clientes (industria, segmento B2B/B2C, país, ciudad, coordenadas).
  - `Sales Orders` – 20,000 líneas de pedido (fechas, cantidades, estados, precios, descuentos, modo de envío, fechas de envío programadas/reales, IVA, COGS, ganancia, indicador de entrega tardía).
  - `Procurement Orders` – 2,000 órdenes de compra (proveedor, producto, fechas planificadas/reales, cantidades, costos).

## 🛠️ Tecnologías Utilizadas
| Herramienta | Uso |
| :--- | :--- |
| **SQL Server** | Modelado, limpieza, consultas analíticas |
| **Python** | Análisis exploratorio, detección de outliers, modelo predictivo |
| **Power BI** | Dashboards interactivos y KPIs |
| **Git/GitHub** | Control de versiones y portafolio |

## 🗂️ Estructura del Repositorio


## 🔍 Preguntas de Negocio que responde el proyecto
- ¿Cómo varían las ventas por región, categoría y segmento de cliente?
- ¿Qué proveedores tienen mayor tasa de entregas tardías?
- ¿Qué productos tienen menor margen de ganancia?
- ¿Se puede predecir una entrega tardía en función del proveedor, modo de envío y fechas?
- ¿Cómo impactan los descuentos y el IVA en la rentabilidad final?

