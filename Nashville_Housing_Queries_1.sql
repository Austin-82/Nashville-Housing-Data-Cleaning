-- Split address column into address and city columns
-- Extract the address part from 'property_address'
SELECT 
SUBSTRING_INDEX(property_address, ',', 1) AS address,
TRIM(LEADING ' ' FROM SUBSTRING_INDEX(property_address, ',', -1)) AS city
FROM nashville_housing

-- Add columns for the split address and city
ALTER TABLE nashville_housing
ADD COLUMN property_split_address VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN property_split_city VARCHAR(255);

-- Update 'property_split_address' column with the address from 'property_address' column
UPDATE nashville_housing
SET property_split_address = SUBSTRING_INDEX(property_address, ',', 1)

-- Update'property_split_city' column with the city from 'property_address' column
UPDATE nashville_housing
SET property_split_city = TRIM(LEADING ' ' FROM SUBSTRING_INDEX(property_address, ',', -1))


-- Split Owner Address into separate columns (address, city, state)
SELECT
    TRIM(SUBSTRING_INDEX(owner_address, ',', 1)) AS street_address,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owner_address, ',', -2), ',', 1)) AS city,
    TRIM(SUBSTRING_INDEX(owner_address, ',', -1)) AS state
FROM nashville_housing;

-- Add columns for the split address, city and state
ALTER TABLE nashville_housing
ADD owner_split_address VARCHAR(255),
ADD owner_split_city VARCHAR(255),
ADD owner_split_state VARCHAR(255);

-- Update the new columns
UPDATE nashville_housing
SET owner_split_address = TRIM(SUBSTRING_INDEX(owner_address, ',', 1)),
	owner_split_city = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owner_address, ',', -2), ',', 1)),
    owner_split_state = TRIM(SUBSTRING_INDEX(owner_address, ',', -1))

-- In sold_as_vacant column, change all 'y' and 'n' to 'Yes' and 'No' respectively
SELECT DISTINCT(sold_as_vacant), count(sold_as_vacant)
FROM nashville_housing
GROUP BY sold_as_vacant
ORDER BY 2

SELECT sold_as_vacant,
CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
	 WHEN sold_as_vacant = 'N' THEN 'No'
     ELSE sold_as_vacant
     END as sold_as_vacant_transformed
FROM nashville_housing

UPDATE nashville_housing
SET sold_as_vacant = 
CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
		 WHEN sold_as_vacant = 'N' THEN 'No'
		 ELSE sold_as_vacant
         END;

-- remove duplicate rows
-- a duplicate row is defined by rows with same parcel_id, property_address, sale_price, sale_date, legal_reference
DELETE 
FROM nashville_housing
WHERE unique_id IN (
	SELECT unique_id
    FROM (
		SELECT unique_id,
			   ROW_NUMBER() OVER (PARTITION BY parcel_id, property_address, sale_price, sale_date, legal_reference
								ORDER BY unique_id) AS row_num
		FROM nashville_housing
	) RankedRows
    WHERE row_num > 1
);
               
