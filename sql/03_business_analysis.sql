-- BUSINESS ANALYSIS

USE swiggy_project;

-- KPI's 

-- 1. Total Orders
SELECT COUNT(*) AS total_orders
FROM fact_swiggy_orders;

-- 2. Total Revenue (INR Million)
SELECT CONCAT(
  FORMAT(SUM(Price_INR) / 1000000, 2),
  ' INR Million'
) AS total_revenue
FROM fact_swiggy_orders;

-- 3. Average order value
SELECT (
  FORMAT(AVG(Price_INR),2)
) 
AS average_order_value
FROM fact_swiggy_orders;

-- 4. Average rating
SELECT (
 FORMAT(AVG(Rating),2)
)
AS average_rating
FROM fact_swiggy_orders;


-- TIME-BASED ANALYSIS

-- Monthly order trends
SELECT 
d.year,
d.month,
d.month_name,
COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d 
ON f.date_id=d.date_id
GROUP BY d.year,d.month, d.month_name
ORDER BY d.year, d.month;

-- Monthly revenue trends
SELECT 
d.year,
d.month,
d.month_name,
CONCAT(FORMAT(SUM(Price_INR)/1000000,2),' INR million') AS revenue
FROM fact_swiggy_orders f
JOIN dim_date d 
ON f.date_id=d.date_id
GROUP BY d.year,d.month, d.month_name
ORDER BY d.year, d.month;

-- Month-over-Month (MoM) Revenue Growth
WITH monthly_revenue AS (
SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(f.price_inr) AS revenue
FROM fact_swiggy_orders f
JOIN dim_date d
ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
)

SELECT
    year,
    month_name,
    revenue,
    LAG(revenue) OVER(ORDER BY year, month) AS previous_month_revenue,
    ROUND(
        ((revenue - LAG(revenue) OVER(ORDER BY year, month))
        / LAG(revenue) OVER(ORDER BY year, month))*100,
        2
    ) AS growth_percentage
FROM monthly_revenue;

-- Quarterly order trend
SELECT 
d.year,
d.quarter,
COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d 
ON f.date_id=d.date_id
GROUP BY d.year, d.quarter;

-- Quarterly revenue trends
SELECT
d.year,
d.quarter,
CONCAT(FORMAT(SUM(Price_INR)/1000000,2), ' INR million') AS revenue
FROM fact_swiggy_orders f
JOIN dim_date d 
ON f.date_id=d.date_id
GROUP BY d.year, d.quarter;

-- Orders by day of the week (Mon-Sun)
SELECT 
   DAYNAME(d.full_date) AS day_name,
   COUNT(*) as total_orders
FROM fact_swiggy_orders f
JOIN dim_date d 
ON f.date_id=d.date_id
GROUP BY DAYNAME(d.full_date), WEEKDAY(d.full_date)
ORDER BY WEEKDAY(d.full_date);


-- GEOGRAPHIC ANALYSIS 

-- Top 10 cities by order volume
SELECT
l.city,
COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_location l
ON l.location_id=f.location_id
GROUP BY l.city
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Revenue contribution by states
SELECT
l.state,
SUM(Price_INR) AS revenue,
ROUND(SUM(Price_INR)*100.0/SUM(SUM(Price_INR)) OVER(),2) AS percentage_contribution
FROM fact_swiggy_orders f
JOIN dim_location l
ON l.location_id=f.location_id
GROUP BY l.state
ORDER BY percentage_contribution DESC;


-- RESTAURANT ANALYSIS

-- Top 10 restaurants by revenue
SELECT
r.restaurant_name,
SUM(Price_INR) AS revenue
FROM fact_swiggy_orders f
JOIN dim_restaurant r
ON r.restaurant_id=f.restaurant_id
GROUP BY r.restaurant_name
ORDER BY SUM(Price_INR) DESC
LIMIT 10;

-- Top 3 Restaurants in Every City
WITH restaurant_rank AS
(
SELECT

    l.city,

    r.restaurant_name,

    SUM(f.price_inr) AS revenue,

    ROW_NUMBER() OVER(
    PARTITION BY l.city
    ORDER BY SUM(f.price_inr) DESC
    ) AS rn

FROM fact_swiggy_orders f

JOIN dim_restaurant r
ON f.restaurant_id=r.restaurant_id

JOIN dim_location l
ON f.location_id=l.location_id

GROUP BY l.city,r.restaurant_name
)

SELECT *
FROM restaurant_rank
WHERE rn<=3;


-- PRODUCT & CUISINE ANALYSIS

-- Top categories by order volume
SELECT
  c.category,
  COUNT(*) AS order_count
FROM fact_swiggy_orders f
JOIN dim_category c
ON c.category_id=f.category_id
GROUP BY c.category
ORDER BY COUNT(*) DESC;

-- Most ordered dishes
SELECT
  d.dish_name,
  COUNT(*) AS order_count
FROM fact_swiggy_orders f
JOIN dim_dish d
ON d.dish_id=f.dish_id
GROUP BY d.dish_name
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Category performance (orders + average rating)
SELECT 
   c.category,
   COUNT(*) AS order_count,
   FORMAT(AVG(f.Rating),2) AS avg_rating
FROM fact_swiggy_orders f
JOIN dim_category c
ON c.category_id=f.category_id
GROUP BY c.category
ORDER BY COUNT(*) DESC;


-- PRICING & RATING ANALYSIS

-- Order count by price range
SELECT
  CASE 
      WHEN price_INR < 100 THEN 'Under 100'
      WHEN price_INR BETWEEN 100 AND 199 THEN '100-199'
	  WHEN price_INR BETWEEN 200 AND 299 THEN '200-299'
      WHEN price_INR BETWEEN 300 AND 399 THEN '300-399'
	  WHEN price_INR BETWEEN 400 AND 499 THEN '400-499'
      ELSE '500 and Above'
	END AS price_range,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders
GROUP BY price_range
ORDER BY
    CASE
        WHEN price_range = 'Under 100' THEN 1
        WHEN price_range = '100-199' THEN 2
        WHEN price_range = '200-299' THEN 3
        WHEN price_range = '300-399' THEN 4
        WHEN price_range = '400-499' THEN 5
        ELSE 6
    END
;

-- Rating distribution (1-5)
SELECT 
   CASE
      WHEN rating BETWEEN 1.0 AND 1.9 THEN '1.0-1.9'
	  WHEN rating BETWEEN 2 AND 2.9 THEN '2.0-2.9'
      WHEN rating BETWEEN 3.0 AND 3.9 THEN '3.0-3.9'
	  WHEN rating BETWEEN 4.0 AND 4.9 THEN '4.0-4.9'
      ELSE '5.0'
	END AS ratings,
    COUNT(*) AS rating_count
FROM fact_swiggy_orders
GROUP BY ratings
ORDER BY MIN(rating);
