-- From this problems, we really need the data form the books. 
-- But i don't have it so i take data form https://github.com/emiliawk/sql_practice_problems
-- To done below problems.


-- 20. Categories, and the total products in each category
SELECT CategoryName,
    Count(*) AS TotalProducts
  FROM Products
  JOIN Categories ON Categories.CategoryID = Products.CategoryID
  GROUP BY CategoryName;

-- 21. Total customers per country/city
SELECT
	City,
	Country,
	COUNT(*)as TotalNumber
  FROM [MicrosoftSQLServer].[dbo].[Customers]
  GROUP BY City, Country
  Order By TotalNumber DESC;

-- 22. Products that need reordering
SELECT [ProductID]
      ,[ProductName]
      ,[UnitsInStock]
      ,[ReorderLevel]
  FROM [MicrosoftSQLServer].[dbo].[Products]
  WHERE UnitsInStock < ReorderLevel
  ORDER By ProductID

-- 23. Products that need reordering, continued
SELECT [ProductID]
      ,[ProductName]
      ,[UnitsInStock]
	  ,[UnitsOnOrder]
      ,[ReorderLevel]
	  ,[Discontinued]
  FROM [MicrosoftSQLServer].[dbo].[Products]
  WHERE UnitsInStock + UnitsOnOrder <= ReorderLevel AND Discontinued = 0
  ORDER By ProductID

-- 24. Customer list by region
-- Not expect can use case when in Order By
SELECT TOP (1000) [CustomerID]
      ,[CompanyName]
      ,[Region]
  FROM [MicrosoftSQLServer].[dbo].[Customers]
  ORDER BY case when Region is null then 1 else 0 end, Region, CustomerID

-- 25. High freight charges
SELECT TOP 3
      [ShipCountry],
	  ROUND(AVG([Freight]), 4) as AverageFreight
  FROM [MicrosoftSQLServer].[dbo].[Orders]
  GROUP BY ShipCountry
  ORDER BY AverageFreight DESC;

-- 26. High freight charger - 2015
SELECT TOP 3
        [ShipCountry],
        ROUND(AVG([Freight]), 4) as AverageFreight
    FROM [MicrosoftSQLServer].[dbo].[Orders]
    WHERE YEAR(OrderDate) = 2015
    GROUP BY ShipCountry
    ORDER BY AverageFreight DESC

-- Using pure things
SELECT TOP 3
        [ShipCountry],
        ROUND(AVG([Freight]), 4) as AverageFreight
    FROM [MicrosoftSQLServer].[dbo].[Orders]
    WHERE CONVERT(DATE, OrderDate) >= '2015-01-01' AND CONVERT(DATE, OrderDate) <= '2015-12-31' 
    GROUP BY ShipCountry
    ORDER BY AverageFreight DESC
    
-- 27. High freight charges between
	SELECT TOP 3
		  [ShipCountry],
		  ROUND(AVG([Freight]), 4) as AverageFreight
	  FROM [MicrosoftSQLServer].[dbo].[Orders]
	  WHERE CONVERT(DATE, OrderDate) between '2015-01-01' and '2015-12-31' 
	  GROUP BY ShipCountry
	  ORDER BY AverageFreight DESC

-- 28. High freight charges - last year
declare  @last_year Date;
set @last_year = (select CONVERT(DATE, DATEADD(month, -12, MAX([OrderDate]))) from [MicrosoftSQLServer].[dbo].[Orders]);

SELECT TOP 3
		[ShipCountry],
		ROUND(AVG([Freight]), 4) as AverageFreight
	FROM [MicrosoftSQLServer].[dbo].[Orders]
	WHERE CONVERT(DATE, OrderDate) >= @last_year
	GROUP BY ShipCountry
	ORDER BY AverageFreight DESC

-- 29. Inventory List
SELECT 
	o.EmployeeID,
	e.LastName,
	o.OrderID,
	p.ProductName,
	od.Quantity
  FROM [MicrosoftSQLServer].[dbo].[Orders] o
  JOIN OrderDetails od ON od.OrderID = o.OrderID
  JOIN Employees e ON e.EmployeeID = o.EmployeeID
  JOIN Products p ON od.ProductID = p.ProductID
  ORDER By o.OrderID, p.ProductID;

-- 30. Customer with no orders
SELECT 
	c.[CustomerID] as Customer_CustomerID,
	o.CustomerID as Orders_CustomerID
  FROM [MicrosoftSQLServer].[dbo].[Customers] c
  LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
  WHERE o.CustomerID IS NULL

-- 31. Customers with no orders for EmployeeID 4
SELECT 
	c.[CustomerID] as CustomerID,
	o.CustomerID as CustomerID
  FROM [MicrosoftSQLServer].[dbo].[Customers] c
  LEFT JOIN Orders o ON c.CustomerID = o.CustomerID AND o.EmployeeID = 4
  WHERE o.CustomerID IS NULL
  ORDER BY c.[CustomerID];
