CREATE DATABASE Ecommerce_Analytics11;
GO

USE Ecommerce_Analytics11;
GO

USE Ecommerce_Analytics11;
GO

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_NAME;


SELECT name
FROM sys.databases;

USE Ecommerce_Analytics11;
GO

SELECT TOP 10 *
FROM dbo.[cleaned ecommerce datset];


SELECT COUNT(*) AS Total_Rows
FROM dbo.[cleaned ecommerce datset];

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'cleaned ecommerce datset';


--- Step 1 — Check total rows ----

SELECT COUNT(*) AS Total_Rows
FROM dbo.[cleaned ecommerce datset];

--- Check for duplicate Order IDs ---
SELECT Order_ID, COUNT(*) AS Order_Count
FROM dbo.[cleaned ecommerce datset]
GROUP BY Order_ID
HAVING COUNT(*) > 1;

--- Check missing values---
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Order_ID,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Order_Date,
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Customer_ID,
    SUM(CASE WHEN Product IS NULL THEN 1 ELSE 0 END) AS Missing_Product,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Missing_Sales,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS Missing_Profit
FROM dbo.[cleaned ecommerce datset];


--- Basic sales summary---
SELECT
    SUM(Sales) AS Total_Sales,
    SUM(Cost) AS Total_Cost,
    SUM(Profit) AS Total_Profit,
    AVG(Sales) AS Average_Sales,
    AVG(Profit) AS Average_Profit
FROM dbo.[cleaned ecommerce datset];



--- 1. Total Sales & Profit ---
SELECT
    SUM(Sales) AS Total_Sales,
    SUM(Cost) AS Total_Cost,
    SUM(Profit) AS Total_Profit
FROM dbo.[cleaned ecommerce datset];

--- 2. Sales by Category---
SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Category
ORDER BY Total_Sales DESC;


--- 3. Top 10 Products by Sales---
SELECT TOP 10
    Product,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Product
ORDER BY Total_Sales DESC;


--- 4. Monthly Sales ---
SELECT
    Year,
    Month,
    Month_Name,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Year, Month, Month_Name
ORDER BY Year, Month;


--- 5. Regional Performance ---

SELECT
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Region
ORDER BY Total_Sales DESC;

--- 6. Payment Method Analysis---
SELECT
    Payment_Method,
    COUNT(*) AS Total_Orders,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Payment_Method
ORDER BY Total_Sales DESC;

--- 7. Top 10 Customers by Sales---

SELECT TOP 10
    Customer_ID,
    Customer_Name,
    COUNT(*) AS Total_Orders,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Sales DESC;

--- 8. Top 10 Products by Profit ---
SELECT TOP 10
    Product,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Product
ORDER BY Total_Profit DESC;


--- 9. Most Profitable Category ---
SELECT
    Category,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit,
    CAST(AVG(Profit) AS decimal(18,2)) AS Average_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Category
ORDER BY Total_Profit DESC;

--- 10. Order Status Analysi---
SELECT
    Order_Status,
    COUNT(*) AS Total_Orders,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Order_Status
ORDER BY Total_Orders DESC;


--- 11. Monthly Growth Analysis---
WITH MonthlySales AS (
    SELECT
        Year,
        Month,
        Month_Name,
        CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales
    FROM dbo.[cleaned ecommerce datset]
    GROUP BY Year, Month, Month_Name
)
SELECT
    Year,
    Month,
    Month_Name,
    Total_Sales,
    LAG(Total_Sales) OVER (ORDER BY Year, Month) AS Previous_Month_Sales,
    CAST(
        (Total_Sales - LAG(Total_Sales) OVER (ORDER BY Year, Month))
        / NULLIF(LAG(Total_Sales) OVER (ORDER BY Year, Month), 0) * 100
        AS decimal(18,2)
    ) AS Growth_Percentage
FROM MonthlySales
ORDER BY Year, Month;


---- 12. Region + Category Performance ---
SELECT
    Region,
    Category,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Region, Category
ORDER BY Total_Profit DESC;


--- 13. Cancelled Orders ---
SELECT
    COUNT(*) AS Cancelled_Orders,
    CAST(SUM(Sales) AS decimal(18,2)) AS Cancelled_Sales
FROM dbo.[cleaned ecommerce datset]
WHERE Order_Status = 'Cancelled';

--- 14. Average Order Value ---

SELECT
    CAST(SUM(Sales) / NULLIF(COUNT(*), 0) AS decimal(18,2)) AS Average_Order_Value
FROM dbo.[cleaned ecommerce datset];

--- 15. Overall Profit Margin ---

SELECT
    CAST(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100
        AS decimal(18,2)
    ) AS Overall_Profit_Margin_Percent
FROM dbo.[cleaned ecommerce datset];

--- 16. Customer Segmentation by Spending ---
WITH CustomerSales AS (
    SELECT
        Customer_ID,
        Customer_Name,
        SUM(Sales) AS Total_Sales
    FROM dbo.[cleaned ecommerce datset]
    GROUP BY Customer_ID, Customer_Name
)
SELECT
    Customer_ID,
    Customer_Name,
    CAST(Total_Sales AS decimal(18,2)) AS Total_Sales,
    CASE
        WHEN Total_Sales >= 100000 THEN 'High Spender'
        WHEN Total_Sales >= 50000 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS Customer_Segment
FROM CustomerSales
ORDER BY Total_Sales DESC;


--- 17. Sales by Year ---
SELECT
    Year,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Year
ORDER BY Year;

--- 18. Best Month by Sales ---
SELECT TOP 1
    Year,
    Month,
    Month_Name,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Year, Month, Month_Name
ORDER BY Total_Sales DESC;

--- 19. Worst Month by Profit ---
SELECT TOP 1
    Year,
    Month,
    Month_Name,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY Year, Month, Month_Name
ORDER BY Total_Profit ASC;

--- 20. Best City by Sales---
SELECT TOP 10
    City,
    CAST(SUM(Sales) AS decimal(18,2)) AS Total_Sales,
    CAST(SUM(Profit) AS decimal(18,2)) AS Total_Profit
FROM dbo.[cleaned ecommerce datset]
GROUP BY City
ORDER BY Total_Sales DESC;