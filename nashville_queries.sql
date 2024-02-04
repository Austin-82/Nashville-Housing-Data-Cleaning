select *
from nashville_housing;

-- convert sale_date to date data type
ALTER TABLE nashville_housing
RENAME COLUMN sale_date TO old_sale_date;

ALTER TABLE nashville_housing
ADD COLUMN sale_date date;

UPDATE nashville_housing
SET sale_date = STR_TO_DATE(old_sale_date, '%M %d, %Y');

ALTER TABLE nashville_housing
DROP COLUMN old_sale_date;


-- Split address column into address and city columns
-- Extract the address part from 'property_address'
SELECT
	SUBSTRING_INDEX(property_address, ',', 1) AS address,
    TRIM(LEADING ' ' FROM SUBSTRING_INDEX(property_address, ',', -1)) AS city
FROM nashville_housing;

-- add columns for the split address and city

ALTER TABLE nashville_housing
ADD COLUMN property_split_address VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN property_split_city VARCHAR(255);

-- Update 'property_split_address' column with the address from 'property_address' column
UPDATE nashville_housing
SET property_split_address = SUBSTRING_INDEX(property_address, ',', 1);

SELECT property_split_address, property_address
FROM nashville_housing;

UPDATE nashville_housing
SET property_split_city = TRIM(LEADING ' ' FROM SUBSTRING_INDEX(property_address, ',', -1));


SELECT 
	owner_address,
    SUBSTRING_INDEX(owner_address, ',', 1) AS owner_split_address,
    TRIM(LEADING ' ' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(owner_address, ',', 2), ',', -1)) AS owner_split_city,
    TRIM(LEADING ' ' FROM SUBSTRING_INDEX(owner_address, ',' ,-1)) AS owner_split_state
FROM nashville_housing;

-- add columns for the split owner address, owner city, and owner state
ALTER TABLE nashville_housing
ADD owner_split_address VARCHAR(255),
ADD owner_split_city VARCHAR(255),
ADD owner_split_state VARCHAR(255);

-- update the new columns
UPDATE nashville_housing
SET owner_split_address = TRIM(SUBSTRING_INDEX(owner_address, ',', 1)),
	owner_split_city = TRIM(LEADING ' ' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(owner_address, ',', 2), ',', -1)),
    owner_split_state = TRIM(SUBSTRING_INDEX(owner_address, ',', -1));


-- identify the distinct values for sold_as_vacant, and count each distinct value occurrence  
SELECT DISTINCT sold_as_vacant, COUNT(sold_as_vacant)
FROM nashville_housing
GROUP BY sold_as_vacant;

-- in sold_as_vacant column, change all 'y' and 'n' to 'Yes' and 'No' respectively
UPDATE nashville_housing
SET sold_as_vacant = (
	CASE 
		WHEN lower(sold_as_vacant) = 'y' THEN 'Yes'
		WHEN lower(sold_as_vacant) = 'n' THEN 'No'
        ELSE sold_as_vacant
        END
);

SELECT DISTINCT sold_as_vacant, COUNT(sold_as_vacant)
FROM nashville_housing
GROUP BY sold_as_vacant;

-- remove duplicate rows
-- a duplicate row is defined by rows with same parcel_id, property_address, sale_price, sale_date, legal_reference
-- first, identify if there are duplicate rows

SELECT 
	unique_id, row_num
FROM
	(
		SELECT
			unique_id,
			ROW_NUMBER() OVER (PARTITION BY parcel_id, property_address, sale_price, sale_date, legal_referance ORDER BY unique_id) AS row_num
		FROM nashville_housing
	) AS rank_rows
WHERE row_num > 1;

-- delete duplicate rows
DELETE
FROM nashville_housing
WHERE unique_id IN
	(
		SELECT 
			unique_id
		FROM
			(
				SELECT
					unique_id,
					ROW_NUMBER() OVER (PARTITION BY parcel_id, property_address, sale_price, sale_date, legal_reference ORDER BY unique_id) AS row_num
				FROM nashville_housing
			) AS rank_rows
		WHERE row_num > 1
	);

-- Verify no duplicates found
SELECT unique_id
FROM 
(
	SELECT
		unique_id,
		ROW_NUMBER() OVER (PARTITION BY parcel_id, property_address, sale_price, sale_date, legal_reference ORDER BY unique_id) AS row_num
	FROM nashville_housing
) AS rank_rows
WHERE row_num > 1




    