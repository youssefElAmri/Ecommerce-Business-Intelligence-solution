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
