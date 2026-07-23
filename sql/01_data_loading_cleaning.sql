-- DATA EXTRACTION AND LOADING
-- 1.Creating a database
CREATE DATABASE swiggy_project;
USE swiggy_project;

-- 2.Creating a table 
CREATE TABLE swiggy_data (
	state VARCHAR(100),
    city VARCHAR(100),
    order_date VARCHAR(50),
    restaurant_name VARCHAR(255),
    location VARCHAR(255),
    category VARCHAR(100),
    dish_name VARCHAR(255),
    price_INR DECIMAL(10,2),
    rating DECIMAL(3,1),
    rating_count INT
);

-- 3.Enable local file loading on the server to allow fast CSV imports
SET GLOBAL local_infile = 1;

-- 4.loading the dataset into the table
LOAD DATA LOCAL INFILE 'path/to/Swiggy_Data.csv'
INTO TABLE swiggy_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- This skips the header row

-- 5.Verify
SELECT*FROM Swiggy_Data;
SELECT COUNT(*) FROM Swiggy_Data;

-- DATA VALIDATION AND CLEANING
-- 1. Null check
SELECT
 SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
 SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
 SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
 SUM(CASE WHEN restaurant_name IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name,
 SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS null_location,
 SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
 SUM(CASE WHEN dish_name IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
 SUM(CASE WHEN price_INR IS NULL THEN 1 ELSE 0 END) AS null_price_INR,
 SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
 SUM(CASE WHEN rating_count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy_data;

-- 2.Blank or Empty strings
SELECT * FROM swiggy_data
WHERE
state='' or city='' or restaurant_name='' or location='' or category='' or dish_name = '';

-- 3.Duplicates check
SELECT
state, city, order_date, restaurant_name, location, category, dish_Name, price_INR, rating, rating_count, COUNT(*) duplicate_count
FROM swiggy_data
GROUP BY state, city, order_date, restaurant_name, location, category, dish_name, price_INR, rating, rating_count
HAVING COUNT(*)>1;

-- 3.1 Delete duplicates
-- 3.1.1 Add unique identifer for each row
ALTER TABLE swiggy_data
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

-- 3.1.2 Delete duplicates
WITH CTE AS
(
SELECT id, ROW_NUMBER() OVER (PARTITION BY state, city, order_date, restaurant_name, location, category, dish_Name, price_INR, rating, rating_count
ORDER BY id
) AS rn
FROM swiggy_data
)
DELETE swiggy_data
FROM swiggy_data
JOIN cte
ON swiggy_data.id = cte.id
WHERE cte.rn > 1;
