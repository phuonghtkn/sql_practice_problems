-- 1. which shippers do we have
SELECT * 
FROM Shipper;
-- 2. Certain fields form categories
SELECT CategoryName, Description 
FROM Shipper;
-- 3. Sales Representatives
SELECT FirstName, LastName, HireDate 
FROM Employeee 
WHERE Title = 'Sales Representative';
-- 4. Sales Representatives in the United States
SELECT FirstName, LastName, HireDate 
FROM Employeee 
WHERE Title = 'Sales Representative'
AND Country = 'USA';

-- 5. Orders places by specific EmployeeID
SELECT * 
FROM Order
WHERE EmployeeId = 5;

-- 6. Suppliers and ContactTitles
SELECT
    SupplierID,
    ContractName,
    ContractTitle
FROM Suppliers
WHERE ContractTitle <> 'Marketing Manager';

-- 7. Products with "queso" in ProductName

-- CONTAINS
CREATE FULLTEXT CATALOG fulltextCatalog AS DEFAULT;   
DROP FULLTEXT INDEX ON DB.Product;

CREATE FULLTEXT INDEX ON DB.Product(ProductName) 
KEY INDEX PK_ProductName_ProductNameNode 
WITH STOPLIST = SYSTEM;

SELECT
    ProductID,
    ProductName
FROM DB.Product
WHERE
    CONTAINS(ProductName, 'queso');

-- Like
SELECT
    ProductID,
    ProductName
FROM DB.Product
WHERE
    ProductName LIKE '%queso%';

-- 8. Orders shipping to France or Belgium
SELECT
    OrderID,
    CustomerID,
    ShipCountry,
FROM Orders
WHERE ShipCountry IN ('France', 'Belgium');

SELECT
    OrderID,
    CustomerID,
    ShipCountry,
FROM Orders
WHERE ShipCountry = 'France' OR ShipCountry = 'Belgium';

-- 9. Orders shipping to any country in Latin America
SELECT
    OrderID,
    CustomerID,
    ShipCountry,
FROM Orders
WHERE ShipCountry IN ('Brazil', 'Mexioc', 'Argentina', 'Venezuela');

-- 10. Employees in order of age
SELECT
    FirstName,
    LastName,
    Title,
    BirthDate
FROM
    Employees
ORDER BY BirthDate

-- 11. Showing only the Date with a DateTime field
SELECT
    FirstName,
    LastName,
    Title,
    CONVERT(DATE, BirthDate) as BirthDate
FROM
    Employees
ORDER BY BirthDate

-- 12. Employees full name
SELECT
    FirstName,
    LastName,
    Title,
    CONCAT(FirstName, ' ', LastName) as FullName
FROM
    Employees

-- 13. OrderDetails amount per line item
SELECT
    OrderID,
    ProductID,
    UnitPrice,
    Quantity,
    UnitPrice * Quantity as TotalPrice
FROM
    OrderDetails

-- 14. How many customers?
SELECT
    COUNT(CustomerID)
FROM
    Customers

-- 15. When was the first order?
SELECT 
    MIN(OrderDate)

-- 16. Countries where there are customers
SELECT
    COUNT(CustomerID),
    Country
FROM
    Customers
GROUP BY
    Country

-- Distinct
SELECT DISTINCT
    Country
FROM
    Customers

-- 17. Contact titles for customers
SELECT
    ContactTitle,
    COUNT(ContactTitle) as TotalContactTitle
FROM
    Customers
GROUP BY
    ContactTitle

-- 18. Products with associated suppliers
SELECT
    p.ProductID,
    p.ProductName,
    s.CompanyName as Supplier
FROM 
    Products as p
    JOIN Suppliers as s ON p.SupplierID = s.SupplierID

-- 19. Orders and the Shipper that was used
SELECT
    OrderID,
    CONVERT(DATE, OrderDate) AS OrderDate,
    Shipper
FROM 
    Orders
    JOIN Shippers ON Orders.ShipVia = Shippers.ShipperID
WHERE
    OrderID < 10300
ORDER BY OrderID
