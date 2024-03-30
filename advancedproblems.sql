-- From this problems, we really need the data form the books. 
-- But i don't have it so i take data form https://github.com/emiliawk/sql_practice_problems
-- To done below problems.

-- 32. High-value customers
-- Have a gap on Having
SELECT 	c.CompanyName,
	o.OrderID,
	SUM(od.Quantity * od.UnitPrice) as TotalOrderAmount
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  JOIN Customers c on o.CustomerID = c.CustomerID
  JOIN OrderDetails od on o.OrderID = od.OrderID
  WHERE YEAR(o.OrderDate) = 2016
  GROUP BY c.CompanyName, o.OrderID
  HAVING SUM(od.Quantity * od.UnitPrice) >= 10000
  ORDER BY TotalOrderAmount DESC

-- If not using Have, we can use subQuery
SELECT p.CompanyName, 
	p.OrderID,
	p.TotalOrderAmount
FROM (SELECT 	c.CompanyName,
	o.OrderID,
	SUM(od.Quantity * od.UnitPrice) as TotalOrderAmount
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  JOIN Customers c on o.CustomerID = c.CustomerID
  JOIN OrderDetails od on o.OrderID = od.OrderID
  WHERE YEAR(o.OrderDate) = 2016
  GROUP BY c.CompanyName, o.OrderID) as p
  WHERE p.TotalOrderAmount >= 10000
  ORDER BY p.TotalOrderAmount DESC

-- If not using Have, we can use Common Table Expressions
WITH p (CompanyName, OrderID, TotalOrderAmount) AS (
SELECT 	c.CompanyName,
	o.OrderID,
	SUM(od.Quantity * od.UnitPrice) as TotalOrderAmount
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  JOIN Customers c on o.CustomerID = c.CustomerID
  JOIN OrderDetails od on o.OrderID = od.OrderID
  WHERE YEAR(o.OrderDate) = 2016
  GROUP BY c.CompanyName, o.OrderID
)
SELECT p.CompanyName, 
	p.OrderID,
	p.TotalOrderAmount
FROM p
  WHERE p.TotalOrderAmount >= 10000
  ORDER BY p.TotalOrderAmount DESC;



-- 33. High-value customers total order
-- Have a gap on Having
SELECT 	c.CompanyName,
	SUM(od.Quantity * od.UnitPrice) as TotalOrderAmount
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  JOIN Customers c on o.CustomerID = c.CustomerID
  JOIN OrderDetails od on o.OrderID = od.OrderID
  WHERE YEAR(o.OrderDate) = 2016
  GROUP BY c.CompanyName
  HAVING SUM(od.Quantity * od.UnitPrice) >= 10000
  ORDER BY TotalOrderAmount DESC

-- 34. High-value customers - with discount
SELECT 	c.CompanyName,
	SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) as TotalOrderAmountWithDiscount,
	SUM(od.Quantity * od.UnitPrice) as TotalOrderAmountWithoutDiscount
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  JOIN Customers c on o.CustomerID = c.CustomerID
  JOIN OrderDetails od on o.OrderID = od.OrderID
  WHERE YEAR(o.OrderDate) = 2016
  GROUP BY c.CompanyName
  HAVING SUM(od.Quantity * od.UnitPrice) >= 10000
  ORDER BY TotalOrderAmountWithDiscount DESC

-- 35. Month-end Orders
SELECT [OrderID]
      ,[EmployeeID]
      ,[OrderDate]
  FROM [MicrosoftSQLServer].[dbo].[Orders]
  WHERE CONVERT(DATE, [OrderDate]) = EOMONTH(CONVERT(DATE, [OrderDate]));

-- 36. Orders with many line items
SELECT TOP (10) o.[OrderID],
      COUNT(*) as TotalOrderDetails
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  JOIN OrderDetails od ON od.OrderID = o.OrderID
  GROUP BY o.OrderID
  ORDER BY TotalOrderDetails DESC;
  
-- 37. Orders - random assortment
-- WITH cte AS (
--     SELECT *, 
-- 	ROW_NUMBER() OVER (ORDER BY RAND()) rn, COUNT(*) OVER () cnt
--     FROM orders
-- )

-- SELECT OrderID
-- FROM cte
-- WHERE rn < 0.02 * cnt;

-- -- Using store procedure
-- -- defined a new procedure to get arround limitations on using a variable with LIMIT
-- DROP PROCEDURE IF EXISTS percentage_of_rows;
-- GO
-- -- SQLINES LICENSE FOR EVALUATION USE ONLY
-- CREATE PROCEDURE percentage_of_rows( @percentage int)
-- AS
-- BEGIN
-- 	SET NOCOUNT ON;

-- 	SELECT TOP (@percentage)
-- 		o.OrderID
-- 		FROM Orders o
-- 		ORDER BY rand();
-- END
-- GO

-- DECLARE @RowNum INT;
-- SET @RowNum = (SELECT ROUND(0.02*COUNT(*),0) FROM Orders);
-- EXEC percentage_of_rows @RowNum;

DECLARE @RowNum INT;
SET @RowNum = (SELECT ROUND(0.02*COUNT(*),0) FROM Orders);
SELECT TOP (@RowNum) OrderID FROM Orders ORDER BY newid()

-- BEST
SELECT TOP 2 PERCENT OrderID FROM Orders ORDER BY newid()

-- 38. Orders - accidental double-entry
SELECT OrderID ,Quantity
FROM OrderDetails
WHERE Quantity >= 60
GROUP BY Quantity,OrderID
HAVING COUNT(OrderID) > 1
ORDER BY OrderID;

-- 39. Orders - accidental double-entry details

WITH cte ( OrderID ) as (
	SELECT DISTINCT OrderID
	FROM OrderDetails
	WHERE Quantity >= 60
	GROUP BY OrderID, Quantity
	HAVING COUNT(OrderID) > 1
) SELECT od.OrderID,
	od.ProductID,
	od.UnitPrice,
	od.Quantity,
	od.Discount
FROM OrderDetails od
INNER JOIN cte c ON c.OrderID = od.OrderID

SELECT od.OrderID,
	od.ProductID,
	od.UnitPrice,
	od.Quantity,
	od.Discount
FROM OrderDetails od
WHERE OrderID IN (
	SELECT DISTINCT OrderID
		FROM OrderDetails
		WHERE Quantity >= 60
		GROUP BY OrderID, Quantity
		HAVING COUNT(OrderID) > 1
	)

-- 40. Orders - accidental double-entry details, derived table
SELECT 
	od.OrderID,
	ProductID,
	UnitPrice,
	Quantity,
	Discount
FROM OrderDetails od
JOIN (
	SELECT DISTINCT
		OrderID
	FROM OrderDetails
	WHERE Quantity >= 60
	GROUP BY OrderID, Quantity
	HAVING COUNT(OrderID) > 1
) pp ON pp.OrderID = od.OrderID
ORDER BY OrderID, ProductID

-- 41. Later Orders
SELECT [OrderID]
      ,[OrderDate]
      ,[RequiredDate]
      ,[ShippedDate]
  FROM [MicrosoftSQLServer].[dbo].[Orders]
  WHERE CONVERT(DATE,RequiredDate) <= CONVERT(DATE,ShippedDate)

-- 42. Later orders - which employees
SELECT o.EmployeeID,
	COUNT(*) as TotalLateOrders
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  INNER JOIN Employees e on e.EmployeeID = o.EmployeeID
  WHERE CONVERT(DATE,RequiredDate) <= CONVERT(DATE,ShippedDate)
  GROUP BY o.EmployeeID
  ORDER BY TotalLateOrders DESC

-- 43. Late orders vs. total orders
WITH cte(EmployeeID, AllOrder) as (
  SELECT EmployeeID, COUNT(*) as AllOrder
  FROM Orders o
  GROUP BY o.EmployeeID),
cte_2(EmployeeID, LateOrder) as (
  SELECT o.EmployeeID,
	  COUNT(*) as LateOrder
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  WHERE CONVERT(DATE,RequiredDate) <= CONVERT(DATE,ShippedDate)
  GROUP BY o.EmployeeID
)
  SELECT 
  e.EmployeeID,
  e.LastName,
  cte.AllOrder,
  cte_2.LateOrder
  FROM cte
  INNER JOIN cte_2 ON cte_2.EmployeeID = cte.EmployeeID
  INNER JOIN Employees e ON e.EmployeeID = cte.EmployeeID
  ORDER BY EmployeeID

-- 44. later orders vs. total orders -- missing employee
WITH cte(EmployeeID, AllOrder) as (
SELECT EmployeeID, COUNT(*) as AllOrder
FROM Orders o
GROUP BY o.EmployeeID),
cte_2(EmployeeID, LateOrder) as (
SELECT o.EmployeeID,
	COUNT(*) as LateOrder
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  WHERE CONVERT(DATE,RequiredDate) <= CONVERT(DATE,ShippedDate)
  GROUP BY o.EmployeeID
)
  SELECT 
  e.EmployeeID,
  e.LastName,
  cte.AllOrder,
  cte_2.LateOrder
  FROM Employees e
  LEFT JOIN cte ON e.EmployeeID = cte.EmployeeID
  LEFT JOIN cte_2 ON e.EmployeeID = cte_2.EmployeeID
  ORDER BY EmployeeID

-- 45. later orders vs. total orders -- fix null

WITH cte(EmployeeID, AllOrder) as (
SELECT EmployeeID, COUNT(*) as AllOrder
FROM Orders o
GROUP BY o.EmployeeID),
cte_2(EmployeeID, LateOrder) as (
SELECT o.EmployeeID,
	COUNT(*) as LateOrder
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  WHERE CONVERT(DATE,RequiredDate) <= CONVERT(DATE,ShippedDate)
  GROUP BY o.EmployeeID
)
  SELECT 
  e.EmployeeID,
  e.LastName,
  cte.AllOrder,
  CASE WHEN  cte_2.LateOrder IS NULL THEN 0 ELSE cte_2.LateOrder END
  FROM Employees e
  LEFT JOIN cte ON e.EmployeeID = cte.EmployeeID
  LEFT JOIN cte_2 ON e.EmployeeID = cte_2.EmployeeID
  ORDER BY EmployeeID

-- ISNULL
WITH cte(EmployeeID, AllOrder) as (
SELECT EmployeeID, COUNT(*) as AllOrder
FROM Orders o
GROUP BY o.EmployeeID),
cte_2(EmployeeID, LateOrder) as (
SELECT o.EmployeeID,
	COUNT(*) as LateOrder
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  WHERE CONVERT(DATE,RequiredDate) <= CONVERT(DATE,ShippedDate)
  GROUP BY o.EmployeeID
)
  SELECT 
  e.EmployeeID,
  e.LastName,
  cte.AllOrder,
  ISNULL(cte_2.LateOrder, 0)
  FROM Employees e
  LEFT JOIN cte ON e.EmployeeID = cte.EmployeeID
  LEFT JOIN cte_2 ON e.EmployeeID = cte_2.EmployeeID
  ORDER BY EmployeeID

-- 46. Late orders vs. total orders -- percentage

WITH cte(EmployeeID, AllOrder) as (
SELECT EmployeeID, COUNT(*) as AllOrder
FROM Orders o
GROUP BY o.EmployeeID),
cte_2(EmployeeID, LateOrder) as (
SELECT o.EmployeeID,
	COUNT(*) as LateOrder
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  WHERE CONVERT(DATE,RequiredDate) <= CONVERT(DATE,ShippedDate)
  GROUP BY o.EmployeeID
)
  SELECT 
  e.EmployeeID,
  e.LastName,
  cte.AllOrder,
  ISNULL(cte_2.LateOrder, 0) as LateOrder,
  CAST(ISNULL(cte_2.LateOrder, 0)as FLoat)/cte.AllOrder 
  FROM Employees e
  LEFT JOIN cte ON e.EmployeeID = cte.EmployeeID
  LEFT JOIN cte_2 ON e.EmployeeID = cte_2.EmployeeID
  ORDER BY EmployeeID

-- 47. Late orders vs. total orders -- fix decimal
WITH cte(EmployeeID, AllOrder) as (
SELECT EmployeeID, COUNT(*) as AllOrder
FROM Orders o
GROUP BY o.EmployeeID),
cte_2(EmployeeID, LateOrder) as (
SELECT o.EmployeeID,
	COUNT(*) as LateOrder
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  WHERE CONVERT(DATE,RequiredDate) <= CONVERT(DATE,ShippedDate)
  GROUP BY o.EmployeeID
)
  SELECT 
  e.EmployeeID,
  e.LastName,
  cte.AllOrder,
  ISNULL(cte_2.LateOrder, 0) as LateOrder,
  ROUND(CAST(ISNULL(cte_2.LateOrder, 0)as FLoat)/cte.AllOrder , 2)
  FROM Employees e
  LEFT JOIN cte ON e.EmployeeID = cte.EmployeeID
  LEFT JOIN cte_2 ON e.EmployeeID = cte_2.EmployeeID
  ORDER BY EmployeeID

-- 48. Customer grouping
 WITH cte ([CustomerID], [CompanyName], TotalOrderAmount) as (
	 SELECT c.[CustomerID]
		  ,c.[CompanyName]
		  ,SUM(od.Quantity * od.UnitPrice) as TotalOrderAmount
	  FROM [dbo].[Customers] c
	  INNER JOIN Orders o On o.CustomerID = c.CustomerID
	  INNER JOIN OrderDetails od On od.OrderID = o.OrderID
	  WHERE YEAR(o.OrderDate) = 2016
	  GROUP BY c.CustomerID, c.[CompanyName] )
SELECT 
	cte.[CustomerID], 
	cte.[CompanyName], 
	cte.TotalOrderAmount,
	cgt.CustomerGroupName
FROM cte
INNER JOIN CustomerGroupThresholds cgt ON cte.TotalOrderAmount >= cgt.RangeBottom AND cte.TotalOrderAmount < cgt.RangeTop

-- With between
 WITH cte ([CustomerID], [CompanyName], TotalOrderAmount) as (
	 SELECT c.[CustomerID]
		  ,c.[CompanyName]
		  ,SUM(od.Quantity * od.UnitPrice) as TotalOrderAmount
	  FROM [dbo].[Customers] c
	  INNER JOIN Orders o On o.CustomerID = c.CustomerID
	  INNER JOIN OrderDetails od On od.OrderID = o.OrderID
	  WHERE YEAR(o.OrderDate) = 2016
	  GROUP BY c.CustomerID, c.[CompanyName] )
SELECT 
	cte.[CustomerID], 
	cte.[CompanyName], 
	cte.TotalOrderAmount,
	cgt.CustomerGroupName
FROM cte
INNER JOIN CustomerGroupThresholds cgt ON cte.TotalOrderAmount BETWEEN cgt.RangeBottom and cgt.RangeTop


--49. Customer grouping - fix null

-- MY answer above not contain null =)))

--50. Customer grouping with percentage
 WITH cte ([CustomerID], [CompanyName], TotalOrderAmount) as (
	 SELECT c.[CustomerID]
		  ,c.[CompanyName]
		  ,SUM(od.Quantity * od.UnitPrice) as TotalOrderAmount
	  FROM [dbo].[Customers] c
	  INNER JOIN Orders o On o.CustomerID = c.CustomerID
	  INNER JOIN OrderDetails od On od.OrderID = o.OrderID
	  WHERE YEAR(o.OrderDate) = 2016
	  GROUP BY c.CustomerID, c.[CompanyName] )
SELECT 
	cgt.CustomerGroupName,
	COUNT(*) as TotalInGroup,
	CONVERT(FLOAT,COUNT(*)) / SUM(CONVERT(FLOAT,COUNT(*))) over() as PercentageInGroup
FROM cte
INNER JOIN CustomerGroupThresholds cgt ON cte.TotalOrderAmount BETWEEN cgt.RangeBottom and cgt.RangeTop
GROUP BY cgt.CustomerGroupName
ORDER BY COUNT(*)

-- Using case when
WITH cte ([CustomerID], [CompanyName], TotalOrderAmount, CustomerGroup) as (
	 SELECT c.[CustomerID]
		  ,c.[CompanyName]
		  ,SUM(od.Quantity * od.UnitPrice) as TotalOrderAmount
		  ,CustomerGroup = (Case 
		  When SUM(od.Quantity * od.UnitPrice) >= 0 and SUM(od.Quantity * od.UnitPrice) < 1000 Then 'Low'
		  When SUM(od.Quantity * od.UnitPrice) >= 1000 and SUM(od.Quantity * od.UnitPrice) < 5000 Then 'Medium'
		  When SUM(od.Quantity * od.UnitPrice) >= 5000 and SUM(od.Quantity * od.UnitPrice) < 10000 Then 'High'
		  When SUM(od.Quantity * od.UnitPrice) >= 10000 Then 'Very High'
		  end) 
	  FROM [dbo].[Customers] c
	  INNER JOIN Orders o On o.CustomerID = c.CustomerID
	  INNER JOIN OrderDetails od On od.OrderID = o.OrderID
	  WHERE YEAR(o.OrderDate) = 2016
	  GROUP BY c.CustomerID, c.[CompanyName] )
SELECT 
	cte.CustomerGroup,
	COUNT(*) as TotalInGroup,
	CONVERT(FLOAT,COUNT(*)) / SUM(CONVERT(FLOAT,COUNT(*))) over() as PercentageInGroup
FROM cte
GROUP BY cte.CustomerGroup
ORDER BY COUNT(*) 

-- Other solution
-- Using subquery
-- Using CTE

--51. Customer grouping - flexible
WITH cte ([CustomerID], [CompanyName], TotalOrderAmount) as (
	 SELECT c.[CustomerID]
		  ,c.[CompanyName]
		  ,SUM(od.Quantity * od.UnitPrice) as TotalOrderAmount
	  FROM [dbo].[Customers] c
	  INNER JOIN Orders o On o.CustomerID = c.CustomerID
	  INNER JOIN OrderDetails od On od.OrderID = o.OrderID
	  WHERE YEAR(o.OrderDate) = 2016
	  GROUP BY c.CustomerID, c.[CompanyName] )
SELECT 
  cte.[CustomerID], 
  cte.[CompanyName], 
  cte.TotalOrderAmount,
  cgt.CustomerGroupName
FROM cte
INNER JOIN CustomerGroupThresholds cgt ON cte.TotalOrderAmount BETWEEN cgt.RangeBottom and cgt.RangeTop

--52. Countries with suppliers or customers
SELECT Country
  FROM [dbo].[Customers]
  UNION
SELECT COUNTRY
  FROM [dbo].[Suppliers];

--53. Countries with suppliers or customers
SELECT Distinct
	c.Country,
	s.Country
  FROM [dbo].[Customers] c
  FULL OUTER JOIN  [dbo].[Suppliers] s ON c.Country = s.Country;

--54. Countries with suppliers or customers

with cte (Country) as (
SELECT Country
  FROM [dbo].[Customers]
  UNION
SELECT Country
  FROM [dbo].[Suppliers]),
cte_customers(Country, TotalCustomers) as
(SELECT 
	cte.Country,
	COUNT(*) as TotalCustomers
	FROM cte
	INNER JOIN [dbo].Customers c ON c.Country = cte.Country
	GROUP BY cte.Country),
cte_suppliers(Country, TotalSuppliers) as
(SELECT 
	cte.Country,
	COUNT(*) as TotalCustomers
	FROM cte
	INNER JOIN [dbo].Suppliers c ON c.Country = cte.Country
	GROUP BY cte.Country)
SELECT 
	ct.Country,
	ISNULL(s.TotalSuppliers, 0) as TotalCustomers,
	ISNULL(c.TotalCustomers, 0) as TotalCustomers
FROM cte ct
FULL OUTER JOIN cte_customers c ON ct.Country = c.Country
FULL OUTER JOIN cte_suppliers s ON ct.Country = s.Country

--55. First order each country

WITH cte( 
	[ShipCountry]
	,[OrderID]
	,[CustomerID]
	,[OrderDate]
	, RowNumberPerCountry) as ( 
	SELECT TOP (1000) 
      [ShipCountry]
	  ,[OrderID]
      ,[CustomerID]
      ,[OrderDate]
	  , RowNumberPerCountry = (
	  ROW_NUMBER() over(PARTITION BY [ShipCountry] ORDER BY [ShipCountry], OrderDate, [OrderID]))
  FROM [MicrosoftSQLServer].[dbo].[Orders])
  SELECT [ShipCountry]
	  ,[OrderID]
      ,[CustomerID]
      ,[OrderDate]
FROM cte
WHERE RowNumberPerCountry = 1

--56. Customer with mutiple orders in 5 day peroid
--57. Customer with mutiple orders in 5 day peroid -- Version 2
