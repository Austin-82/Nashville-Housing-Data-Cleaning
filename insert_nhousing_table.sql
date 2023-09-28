--Create MySQL table to prepare for CSV loading
use nashville_housing
CREATE TABLE nashville_housing
(unique_id INT,
parcel_id VARCHAR(255),
land_use VARCHAR(255),
property_address VARCHAR(255),
sale_date VARCHAR(255),
sale_price DOUBLE,
legal_referance VARCHAR(255),
sold_as_vacant VARCHAR(255),
owner_name VARCHAR(255),
owner_address VARCHAR(255),
acreage	DOUBLE,
tax_district DOUBLE,
land_value DOUBLE,
building_value DOUBLE,
total_value	DOUBLE,
year_built INT,
bedrooms INT,
full_bath INT,
half_bath INT);

--load csv file into MySQL. If cell is empty, input null
LOAD DATA lOCAL INFILE '/Users/austinshirk/Documents/cs/Projects/Nashville_Housing/Nashville Housing Data.csv'
INTO TABLE nashville_housing
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@col1, @col2, @col3, @col4, @col5, @col6, @col7, @col8, @col9, 
@col10, @col11, @col12, @col13, @col14, @col15, @col16, @col17, 
@col18, @col19)
SET
	unique_id = IF(@col1 = '', NULL, @col1),
    parcel_id = IF(@col2 = '', NULL, @col2),
    land_use = IF(@col3 = '', NULL, @col3),
    property_address = IF(@col4 = '', NULL, @col4),
    sale_date = IF(@col5 = '', NULL, @col5),
    sale_price = IF(@col6 = '', NULL, @col6),
    legal_referance = IF(@col7 = '', NULL, @col7),
    sold_as_vacant = IF(@col8 = '', NULL, @col8),
    owner_name = IF(@col9 = '', NULL, @col9),
    owner_address = IF(@col10 = '', NULL, @col10),
    acreage = IF(@col11 = '', NULL, @col11),
    tax_district = IF(@col12 = '', NULL, @col12),
    land_value = IF(@col13 = '', NULL, @col13),
    building_value =IF(@col14 = '', NULL, @col14),
    total_value = IF(@col15 = '', NULL, @col15),
    year_built = IF(@col16 = '', NULL, @col16),
    bedrooms = IF(@col17 = '', NULL, @col17),
    full_bath = IF(@col18 = '', NULL, @col18),
    half_bath = IF(@col19 = '', NULL, @col19);
	
--Change 'sale_date' column datatype from string to date datatype
-- Rename the original 'sale_date' column to 'old_sale_date'
ALTER TABLE nashville_housing
RENAME COLUMN sale_date TO old_sale_date;

--Add a 'sale_date' column with date datatype
ALTER TABLE nashville_housing
ADD COLUMN sale_date date;

-- Update the 'sale_date' column by converting 'old_sale_date' string values to date datatype.
UPDATE nashville_housing
SET sale_date = STR_TO_DATE(old_sale_date, '%d-%b-%y');




