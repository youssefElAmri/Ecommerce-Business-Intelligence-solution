-- Backup FactEcommerce table
SELECT * INTO FactEcommerce_Backup
FROM FactEcommerce;

-- Check for values that cannot be converted to INT
SELECT DISTINCT DeliveryRating
FROM FactEcommerce
WHERE DeliveryRating IS NOT NULL AND TRY_CAST(DeliveryRating AS INT) IS NULL;

SELECT DISTINCT ProductRating
FROM FactEcommerce
WHERE ProductRating IS NOT NULL AND TRY_CAST(ProductRating AS INT) IS NULL;

ALTER TABLE FactEcommerce
ADD DeliveryRating_TEMP INT;

ALTER TABLE FactEcommerce
ADD ProductRating_TEMP INT;

UPDATE FactEcommerce
SET DeliveryRating_TEMP = CAST(DeliveryRating AS INT);

UPDATE FactEcommerce
SET ProductRating_TEMP = CAST(ProductRating AS INT);

ALTER TABLE FactEcommerce
DROP COLUMN DeliveryRating;

ALTER TABLE FactEcommerce
DROP COLUMN ProductRating;


EXEC sp_rename 'FactEcommerce.DeliveryRating_TEMP', 'DeliveryRating', 'COLUMN';

EXEC sp_rename 'FactEcommerce.ProductRating_TEMP', 'ProductRating', 'COLUMN';

-- Check the schema of FactEcommerce to verify column types
EXEC sp_columns 'FactEcommerce';

-- Verify data in updated columns
SELECT TOP 10 DeliveryRating, ProductRating
FROM FactEcommerce;



