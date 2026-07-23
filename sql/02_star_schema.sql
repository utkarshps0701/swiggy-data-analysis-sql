-- CREATING STAR SCHEMA

USE swiggy_project;

-- 1. Creating dimension tables

-- 1.1 Creating Date Table
CREATE TABLE dim_date(
date_id INT AUTO_INCREMENT PRIMARY KEY,
full_date DATE,
year INT,
month INT,
month_name VARCHAR(20),
quarter INT,
day INT,
week INT
);

-- 1.2 Create location table
CREATE TABLE dim_location(
location_id INT AUTO_INCREMENT PRIMARY KEY,
state VARCHAR (100),
city VARCHAR(100),
location VARCHAR(200)
);

-- 1.3 Creating dim_restaurant
CREATE TABLE dim_restaurant(
restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
restaurant_name VARCHAR (200)
);

-- 1.4 Creating dim_category
CREATE TABLE dim_category(
category_id INT AUTO_INCREMENT PRIMARY KEY,
category VARCHAR (200)
);

-- 1.5 Creating dim_dish
CREATE TABLE dim_dish(
dish_id INT AUTO_INCREMENT PRIMARY KEY,
dish_name VARCHAR (200)
);


-- 2. Creating fact table

CREATE TABLE fact_swiggy_orders (
order_id INT AUTO_INCREMENT PRIMARY KEY,

date_id INT,
Price_INR DECIMAL (10,2),
Rating DECIMAL (4,2),
Rating_Count INT,

location_id INT,
restaurant_id INT,
category_id INT,
dish_id INT,

FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);



-- INSERT DATA IN DIMENSION TABLES 

-- 1. dim_date
INSERT INTO dim_date (full_date, year, month, month_name, quarter, day, week)
SELECT DISTINCT
    STR_TO_DATE(order_date, '%d-%m-%Y'),
    YEAR(STR_TO_DATE(order_date, '%d-%m-%Y')),
    MONTH(STR_TO_DATE(order_date, '%d-%m-%Y')),
    MONTHNAME(STR_TO_DATE(order_date, '%d-%m-%Y')),
    QUARTER(STR_TO_DATE(order_date, '%d-%m-%Y')),
    DAY(STR_TO_DATE(order_date, '%d-%m-%Y')),
    WEEK(STR_TO_DATE(order_date, '%d-%m-%Y'))
FROM swiggy_data
WHERE order_date IS NOT NULL;


-- 2. dim_location
INSERT INTO dim_location (state, city, location)
SELECT DISTINCT 
  state,
  city,
  location
FROM swiggy_data;


-- 3. dim_restaurant
INSERT INTO dim_restaurant (restaurant_name)
SELECT DISTINCT 
 restaurant_name
FROM swiggy_data;


-- 4. dim_category 
INSERT INTO dim_category (category)
SELECT DISTINCT
 category
FROM swiggy_data;


-- 5. dim_dish
INSERT INTO dim_dish(dish_name)
SELECT DISTINCT
  dish_name
FROM swiggy_data;



-- INSERTING DATA IN FACT TABLE

INSERT INTO fact_swiggy_orders(
    date_id, 
    Price_INR, 
    Rating, 
    Rating_Count,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)
SELECT 
    dd.date_id,
    s.price_INR,
    s.rating,
    s.rating_count,
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    ddsh.dish_id
FROM swiggy_data s

JOIN dim_date dd
  ON dd.full_date = STR_TO_DATE(s.order_date, '%d-%m-%Y')

JOIN dim_location dl
  ON dl.state=s.state
  AND dl.city=s.city
  AND dl.location=s.location

JOIN dim_restaurant dr
  ON dr.restaurant_name=s.restaurant_name
 
JOIN dim_category dc
  ON dc.category=s.category
 
JOIN dim_dish ddsh
  ON ddsh.dish_name=s.dish_name;
 

SELECT * FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id=d.date_id
JOIN dim_location l ON f.location_id=l.location_id
JOIN dim_restaurant r ON f.restaurant_id=r.restaurant_id
JOIN dim_category c ON f.category_id=c.category_id
JOIN dim_dish di ON f.dish_id=di.dish_id;
