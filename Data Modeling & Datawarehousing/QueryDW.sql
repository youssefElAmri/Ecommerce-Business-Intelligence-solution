-- Staging DimCustomer
CREATE TABLE StagingDimCustomer (
    CustomerID NVARCHAR(50),
    Gender NVARCHAR(10),
    Country NVARCHAR(50)
);

-- Staging DimProduct
CREATE TABLE StagingDimProduct (
    ProductID NVARCHAR(50),
    Price NVARCHAR(50),
    DeviceCategory NVARCHAR(50),
    Device NVARCHAR(50),
    OS NVARCHAR(50)
);

-- Staging DimInvoice
CREATE TABLE StagingDimInvoice (
    InvoiceNumber NVARCHAR(50),
    InvoiceDate NVARCHAR(50)
);

-- Staging FactEcommerce
CREATE TABLE StagingFactEcommerce (
    FactID NVARCHAR(50),
    CustomerID NVARCHAR(50),
    InvoiceNumber NVARCHAR(50),
    ProductID NVARCHAR(50),
    Quantity NVARCHAR(50),
    Total NVARCHAR(50),
    OrderStatus NVARCHAR(50),
    TrafficSource NVARCHAR(50),
    SessionDuration NVARCHAR(50),
    DeliveryRating NVARCHAR(50),
    ProductRating NVARCHAR(50),
    Sales NVARCHAR(50)
);


DELETE FROM StagingDimCustomer
WHERE CustomerID NOT IN (SELECT MIN(CustomerID) FROM StagingDimCustomer GROUP BY CustomerID);

DELETE FROM StagingDimProduct
WHERE ProductID NOT IN (SELECT MIN(ProductID) FROM StagingDimProduct GROUP BY ProductID);

DELETE FROM StagingDimInvoice
WHERE InvoiceNumber NOT IN (SELECT MIN(InvoiceNumber) FROM StagingDimInvoice GROUP BY InvoiceNumber);

DELETE FROM StagingFactEcommerce
WHERE FactID NOT IN (SELECT MIN(FactID) FROM StagingFactEcommerce GROUP BY FactID);

--creating final tables

-- Final DimCustomer
CREATE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY,
    Gender NVARCHAR(10),
    Country NVARCHAR(50)
);

-- Final DimProduct
CREATE TABLE DimProduct (
    ProductID INT PRIMARY KEY,
    Price DECIMAL(10, 2),
    DeviceCategory NVARCHAR(50),
    Device NVARCHAR(50),
    OS NVARCHAR(50)
);

-- Final DimInvoice
CREATE TABLE DimInvoice (
    InvoiceNumber NVARCHAR(50) PRIMARY KEY,
    InvoiceDate DATE
);

-- Final FactEcommerce
CREATE TABLE FactEcommerce (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    InvoiceNumber NVARCHAR(50),
    ProductID INT,
    Quantity INT,
    Total DECIMAL(10, 2),
    OrderStatus NVARCHAR(50),
    TrafficSource NVARCHAR(50),
    SessionDuration DECIMAL(10, 2),
    DeliveryRating DECIMAL(3, 1),
    ProductRating DECIMAL(3, 1),
    Sales DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
    FOREIGN KEY (InvoiceNumber) REFERENCES DimInvoice(InvoiceNumber)
);


-------------------------------

-- Find duplicate InvoiceNumber in StagingDimInvoice
SELECT InvoiceNumber, COUNT(*)
FROM StagingDimInvoice
GROUP BY InvoiceNumber
HAVING COUNT(*) > 1;

-- Find duplicate ProductID in StagingDimProduct
SELECT ProductID, COUNT(*)
FROM StagingDimProduct
GROUP BY ProductID
HAVING COUNT(*) > 1;

-- Remove duplicate InvoiceNumber from StagingDimInvoice
;WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY InvoiceNumber ORDER BY (SELECT NULL)) AS rn
    FROM StagingDimInvoice
)
DELETE FROM CTE
WHERE rn > 1;

-- Remove duplicate ProductID from StagingDimProduct
;WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY (SELECT NULL)) AS rn
    FROM StagingDimProduct
)
DELETE FROM CTE
WHERE rn > 1;

-- For numeric columns in StagingFactEcommerce
UPDATE StagingFactEcommerce
SET Quantity = NULL
WHERE ISNUMERIC(Quantity) = 0;

UPDATE StagingFactEcommerce
SET Total = NULL
WHERE ISNUMERIC(Total) = 0;

UPDATE StagingFactEcommerce
SET SessionDuration = NULL
WHERE ISNUMERIC(SessionDuration) = 0;

UPDATE StagingFactEcommerce
SET DeliveryRating = NULL
WHERE ISNUMERIC(DeliveryRating) = 0;

UPDATE StagingFactEcommerce
SET ProductRating = NULL
WHERE ISNUMERIC(ProductRating) = 0;

UPDATE StagingFactEcommerce
SET Sales = NULL
WHERE ISNUMERIC(Sales) = 0;

----

SELECT InvoiceNumber, COUNT(*)
FROM StagingDimInvoice
GROUP BY InvoiceNumber
HAVING COUNT(*) > 1;

;WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY InvoiceNumber ORDER BY (SELECT NULL)) AS rn
    FROM StagingDimInvoice
)
DELETE FROM CTE
WHERE rn > 1;

UPDATE StagingDimInvoice
SET InvoiceDate = NULL
WHERE ISDATE(InvoiceDate) = 0;

INSERT INTO DimInvoice (InvoiceNumber, InvoiceDate)
SELECT 
    InvoiceNumber,
    CASE 
        WHEN ISDATE(InvoiceDate) = 1 THEN CAST(InvoiceDate AS DATE)
        ELSE NULL
    END
FROM StagingDimInvoice;

-------------------------



-- Set non-numeric values to NULL for all numeric columns
UPDATE StagingFactEcommerce
SET Quantity = NULL
WHERE ISNUMERIC(Quantity) = 0;

UPDATE StagingFactEcommerce
SET Total = NULL
WHERE ISNUMERIC(Total) = 0;

UPDATE StagingFactEcommerce
SET SessionDuration = NULL
WHERE ISNUMERIC(SessionDuration) = 0;

UPDATE StagingFactEcommerce
SET DeliveryRating = NULL
WHERE ISNUMERIC(DeliveryRating) = 0;

UPDATE StagingFactEcommerce
SET ProductRating = NULL
WHERE ISNUMERIC(ProductRating) = 0;

UPDATE StagingFactEcommerce
SET Sales = NULL
WHERE ISNUMERIC(Sales) = 0;


-- Check for invalid CustomerID
SELECT DISTINCT CustomerID
FROM StagingFactEcommerce
WHERE CustomerID NOT IN (SELECT CustomerID FROM DimCustomer);

-- Check for invalid ProductID
SELECT DISTINCT ProductID
FROM StagingFactEcommerce
WHERE ProductID NOT IN (SELECT ProductID FROM DimProduct);

-- Check for invalid InvoiceNumber
SELECT DISTINCT InvoiceNumber
FROM StagingFactEcommerce
WHERE InvoiceNumber NOT IN (SELECT InvoiceNumber FROM DimInvoice);







-- Remove records with invalid CustomerID
DELETE FROM StagingFactEcommerce
WHERE CustomerID NOT IN (SELECT CustomerID FROM DimCustomer);

-- Remove records with invalid ProductID
DELETE FROM StagingFactEcommerce
WHERE ProductID NOT IN (SELECT ProductID FROM DimProduct);

-- Remove records with invalid InvoiceNumber
DELETE FROM StagingFactEcommerce
WHERE InvoiceNumber NOT IN (SELECT InvoiceNumber FROM DimInvoice);



-- Find non-numeric values in Quantity
SELECT DISTINCT Quantity
FROM StagingFactEcommerce
WHERE ISNUMERIC(Quantity) = 0;

-- Find non-numeric values in Total
SELECT DISTINCT Total
FROM StagingFactEcommerce
WHERE ISNUMERIC(Total) = 0;

-- Find non-numeric values in SessionDuration
SELECT DISTINCT SessionDuration
FROM StagingFactEcommerce
WHERE ISNUMERIC(SessionDuration) = 0;

-- Find non-numeric values in DeliveryRating
SELECT DISTINCT DeliveryRating
FROM StagingFactEcommerce
WHERE ISNUMERIC(DeliveryRating) = 0;

-- Find non-numeric values in ProductRating
SELECT DISTINCT ProductRating
FROM StagingFactEcommerce
WHERE ISNUMERIC(ProductRating) = 0;

-- Find non-numeric values in Sales
SELECT DISTINCT Sales
FROM StagingFactEcommerce
WHERE ISNUMERIC(Sales) = 0;







-- Set non-numeric values to NULL for Quantity
UPDATE StagingFactEcommerce
SET Quantity = NULL
WHERE ISNUMERIC(Quantity) = 0;

-- Set non-numeric values to NULL for Total
UPDATE StagingFactEcommerce
SET Total = NULL
WHERE ISNUMERIC(Total) = 0;

-- Set non-numeric values to NULL for SessionDuration
UPDATE StagingFactEcommerce
SET SessionDuration = NULL
WHERE ISNUMERIC(SessionDuration) = 0;

-- Set non-numeric values to NULL for DeliveryRating
UPDATE StagingFactEcommerce
SET DeliveryRating = NULL
WHERE ISNUMERIC(DeliveryRating) = 0;

-- Set non-numeric values to NULL for ProductRating
UPDATE StagingFactEcommerce
SET ProductRating = NULL
WHERE ISNUMERIC(ProductRating) = 0;

-- Set non-numeric values to NULL for Sales
UPDATE StagingFactEcommerce
SET Sales = NULL
WHERE ISNUMERIC(Sales) = 0;





-- Check for remaining non-numeric values
SELECT DISTINCT Quantity FROM StagingFactEcommerce WHERE ISNUMERIC(Quantity) = 0;
SELECT DISTINCT Total FROM StagingFactEcommerce WHERE ISNUMERIC(Total) = 0;
SELECT DISTINCT SessionDuration FROM StagingFactEcommerce WHERE ISNUMERIC(SessionDuration) = 0;
SELECT DISTINCT DeliveryRating FROM StagingFactEcommerce WHERE ISNUMERIC(DeliveryRating) = 0;
SELECT DISTINCT ProductRating FROM StagingFactEcommerce WHERE ISNUMERIC(ProductRating) = 0;
SELECT DISTINCT Sales FROM StagingFactEcommerce WHERE ISNUMERIC(Sales) = 0;




-- Transform and Load Data into FactEcommerce
INSERT INTO FactEcommerce (CustomerID, InvoiceNumber, ProductID, Quantity, Total, OrderStatus, TrafficSource, SessionDuration, DeliveryRating, ProductRating, Sales)
SELECT 
    CAST(CustomerID AS INT),
    InvoiceNumber,
    CAST(ProductID AS INT),
    TRY_CAST(Quantity AS INT),
    TRY_CAST(Total AS DECIMAL(10, 2)),
    OrderStatus,
    TrafficSource,
    TRY_CAST(SessionDuration AS DECIMAL(10, 2)),
    TRY_CAST(DeliveryRating AS DECIMAL(3, 1)),
    TRY_CAST(ProductRating AS DECIMAL(3, 1)),
    TRY_CAST(Sales AS DECIMAL(10, 2))
FROM StagingFactEcommerce;











