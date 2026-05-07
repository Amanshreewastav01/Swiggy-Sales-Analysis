CREATE DATABASE Swiggy_DB;

USE Swiggy_DB;

/* Table Creation */
CREATE TABLE swiggy_data (
    state VARCHAR(100),
    city VARCHAR(100),
    order_date DATE,
    restaurant_name VARCHAR(255),
    location VARCHAR(255),
    category VARCHAR(100),
    dish_name VARCHAR(255),
    price_inr DECIMAL(10,2),
    rating DECIMAL(3,1),
    rating_count INT
);

/* Local Infile = ON */
/*
CMD Prompt
1). "cd C:\Program Files\MySQL\MySQL Server 8.0\bin"
2). "mysql -u root -p --local-infile=1"
3). "SHOW GLOBAL VARIABLES LIKE 'local_infile';"
4). "SET GLOBAL local_infile = 1;"
5). "SHOW GLOBAL VARIABLES LIKE 'local_infile';"
*/
SHOW VARIABLES LIKE 'local_infile';

/* Data Import */
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/swiggy_data.csv'
INTO TABLE swiggy_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(state, city, @order_date, restaurant_name, location, category,
 dish_name, price_inr, rating, rating_count)
SET order_date = STR_TO_DATE(@order_date, '%d-%m-%Y');

/* Data Validation & Cleaning*/

SELECT * FROM swiggy_data;

SELECT COUNT(*) FROM swiggy_data;

DESCRIBE swiggy_data;

-- (1). Null Check
SELECT
SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS state_count,
SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_count,
SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_count,
SUM(CASE WHEN restaurant_name IS NULL THEN 1 ELSE 0 END) AS restaurant_name_count,
SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS location_count,
SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_count,
SUM(CASE WHEN dish_name IS NULL THEN 1 ELSE 0 END) AS dish_name_count,
SUM(CASE WHEN price_inr IS NULL THEN 1 ELSE 0 END) AS price_inr_count,
SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_count,
SUM(CASE WHEN rating_count IS NULL THEN 1 ELSE 0 END) AS rating_count_count
FROM swiggy_data;

-- (2). Blank 0r Empty Strings
SELECT * 
FROM swiggy_data
WHERE state ='' OR city ='' OR restaurant_name ='' OR location ='' OR category ='' OR dish_name ='';

-- (3). Duplicate Detection
SELECT state, city, order_date, restaurant_name, location, category, dish_name, price_inr, rating, rating_count, COUNT(*) AS CNT
FROM swiggy_data
GROUP BY state, city, order_date, restaurant_name, location, category, dish_name, price_inr, rating, rating_count
HAVING count(*)>1;

-- (4). Delete Duplication
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE swiggy_data 
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

DELETE FROM swiggy_data
WHERE id IN (
    SELECT id FROM (
        SELECT id,
               ROW_NUMBER() OVER (
                   PARTITION BY state, city, order_date, restaurant_name, location, 
                                category, dish_name, price_inr, rating, rating_count
                   ORDER BY id
               ) AS rn
        FROM swiggy_data
    ) t
    WHERE rn > 1
);

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE swiggy_data 
MODIFY id INT;

ALTER TABLE swiggy_data 
DROP PRIMARY KEY;

ALTER TABLE swiggy_data 
DROP COLUMN id;

/* Creating Schema */
/* Dimension Table */
-- (1). Date Table

CREATE TABLE dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    week INT,
    day INT
);

-- (2). Location Table

CREATE TABLE dim_location (
location_id INT AUTO_INCREMENT PRIMARY KEY,
state VARCHAR (100),
city VARCHAR (100),
location VARCHAR (255)
);

-- (3). Restaurant Table

CREATE TABLE dim_restaurant (
restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
restaurant_name VARCHAR (255)
);

-- (4). Category Table

CREATE TABLE dim_category (
category_id INT AUTO_INCREMENT PRIMARY KEY,
category VARCHAR (100)
);

-- (5). Dish Table

CREATE TABLE dim_dish (
dish_id INT AUTO_INCREMENT PRIMARY KEY,
dish_name VARCHAR (255)
);

/* Fact Table */

CREATE TABLE fact_swiggy_orders (
order_id INT AUTO_INCREMENT PRIMARY KEY,

date_id INT,
price_inr DECIMAL(10,2),
rating DECIMAL(3,1),
rating_count INT,

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

/* Insert Data In Table */

-- (1). Dim_Date

INSERT INTO dim_date(full_date, year, month, month_name, quarter, week , day)
SELECT DISTINCT
order_date,
year(order_date),
month(order_date),
monthname(order_date),
quarter(order_date),
week(order_date),
day(order_date)
FROM swiggy_data
WHERE order_date IS NOT NULL;

-- (2). Dim_Location

INSERT INTO dim_location(state, city, location)
SELECT DISTINCT
state,
city,
location
FROM swiggy_data;

-- (3). Dim_Restaurant

INSERT INTO dim_restaurant (restaurant_name)
SELECT DISTINCT
restaurant_name
FROM swiggy_data;

-- (4). Dim_Category

INSERT INTO dim_category(category)
SELECT DISTINCT
category
FROM swiggy_data;

-- (5). Dim_Dish

INSERT INTO dim_dish(dish_name)
SELECT DISTINCT
dish_name
FROM swiggy_data;

-- (6). Fact_Swiggy_Orders

-- 1st Step
SET FOREIGN_KEY_CHECKS = 0;

-- 2nd Step
TRUNCATE TABLE fact_swiggy_orders;

-- 3rd Step
SELECT * FROM fact_swiggy_orders;

SELECT COUNT(*) FROM fact_swiggy_orders;

-- 4th Step
INSERT INTO fact_swiggy_orders 
(
date_id,
price_inr,
rating,
rating_count,
location_id,
restaurant_id,
category_id,
dish_id
)
SELECT 
dd.date_id,
s.price_inr,
s.rating,
s.rating_count,

dl.location_id,
dr.restaurant_id,
dc.category_id,
ds.dish_id
FROM swiggy_data s

JOIN dim_date dd
ON dd.full_date = s.order_Date

JOIN dim_location dl
ON dl.state = s.state
AND dl.city = s.city
AND dl.location = s.location

JOIN dim_restaurant dr
ON dr.restaurant_name = s.restaurant_name

JOIN dim_category dc
ON dc.category = s.category

JOIN dim_dish ds
ON ds.dish_name = s.dish_name ;

-- 5th Step
SELECT * FROM fact_swiggy_orders f
JOIN dim_date dd ON f.date_id = dd.date_id
JOIN dim_location dl on f.location_id = dl.location_id
JOIN dim_restaurant dr on f.restaurant_id = dr.restaurant_id
JOIN dim_category dc on f.category_id = dc.category_id
JOIN dim_dish ds on f.dish_id = ds.dish_id
order by f.order_id;

/* KPIs */
-- Total Orders
SELECT COUNT(*) AS total_orders
FROM fact_swiggy_orders;

-- Total Revenue (INR Million)
SELECT CONCAT(ROUND(SUM(price_inr)/1000000,2)," INR Million") AS total_revenue
FROM fact_swiggy_orders;

-- Average Dish Price
SELECT CONCAT(ROUND(AVG(price_inr),2)," INR") AS avg_dish_price
FROM fact_swiggy_orders;

-- Average Rating
SELECT ROUND(AVG(rating),2) AS avg_rating
FROM fact_swiggy_orders;

/* Deep-Dive Business Analysis */
/* (A) Date-Based Analysis */
-- (1). Monthly order trends

SELECT
d.year,
d.month,
d.month_name,
COUNT(order_id) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON  f.date_id = d.date_id
GROUP BY 
d.year,
d.month,
d.month_name
ORDER BY COUNT(order_id) DESC;

-- (2). Monthly Revenue trends

SELECT 
d.year,
d.month,
d.month_name,
SUM(price_inr) AS total_revenue
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY
d.year,
d.month,
d.month_name
ORDER BY SUM(price_inr) DESC;

-- (3). Quarterly order trends

SELECT
d.year,
d.quarter,
COUNT(order_id) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY 
d.year,
d.quarter
ORDER BY COUNT(order_id) DESC;

-- (4). Quarterly Revenue trends

SELECT 
d.year,
d.quarter,
SUM(price_inr) AS total_revenue
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY
d.year,
d.quarter
ORDER BY SUM(price_inr) DESC;

-- (5). Yearly Trends

SELECT
d.year,
COUNT(order_id) AS total_orders,
SUM(price_inr) AS total_revenue
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year

-- (6). Orders & Revenue By Day-Of-Week Patterns

SELECT 
    DAYNAME(d.full_date) AS day_name,
    DAYOFWEEK(d.full_date) AS day_num,
    COUNT(f.order_id) AS total_orders,
    SUM(f.price_inr) AS total_revenue
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY 
    day_name, day_num
ORDER BY 
    day_num;

/* (B) Location-Based Analysis */
-- (1). Top 10 cities by order volume

SELECT
l.city,
COUNT(f.order_id) as total_orders
FROM fact_swiggy_orders f
JOIN dim_location l ON l.location_id = f.location_id
GROUP BY city
ORDER BY total_orders DESC
LIMIT 10;

-- (2). Revenue contribution by states

SELECT
l.state,
COUNT(f.order_id) as total_orders
FROM fact_swiggy_orders f
JOIN dim_location l ON l.location_id = f.location_id
GROUP BY state
ORDER BY total_orders DESC;

/* (C) Food Performance Analysis */
-- (1). Top 10 restaurants by orders

SELECT
r.restaurant_name,
COUNT(f.order_id) as total_orders
FROM fact_swiggy_orders f
JOIN dim_restaurant r ON r.restaurant_id = f.restaurant_id
GROUP BY restaurant_name
ORDER BY total_orders DESC;

-- (2). Top categories (Indian, Chinese, etc.)

SELECT
c.category,
COUNT(f.order_id) as total_orders
FROM fact_swiggy_orders f
JOIN dim_category c ON c.category_id = f.category_id
GROUP BY category
ORDER BY total_orders DESC;

-- (3). Most ordered dishes

SELECT
d.dish_name,
COUNT(f.order_id) as total_orders
FROM fact_swiggy_orders f
JOIN dim_dish d ON d.dish_id = f.dish_id
GROUP BY dish_name
ORDER BY total_orders DESC
LIMIT 5;

-- (4). Cuisine performance → Orders + Avg Rating

SELECT
d.dish_name,
COUNT(f.order_id) AS total_orders,
AVG(f.rating) AS avg_rating
FROM fact_swiggy_orders f
JOIN dim_dish d ON d.dish_id = f.dish_id
GROUP BY dish_name
ORDER BY avg_rating DESC, total_orders DESC;

/* (D) Customer Spending Insights */
/*
Buckets of customer spend:
•	Under 100
•	100–199
•	200–299
•	300–499
•	500+
With total order distribution across these ranges.
*/
SELECT
    CASE
        WHEN price_inr <= 100 THEN 'Under 100'
        WHEN price_inr BETWEEN 101 AND 199 THEN '101-199'
        WHEN price_inr BETWEEN 200 AND 299 THEN '200-299'
        WHEN price_inr BETWEEN 300 AND 399 THEN '300-399'
        WHEN price_inr BETWEEN 400 AND 499 THEN '400-499'
        ELSE '500+'
    END AS price_dispersion,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders
GROUP BY price_dispersion
ORDER BY 
    MIN(price_inr);

/* (E) Ratings Analysis*/
-- (4). Distribution of dish ratings from 1–5.

SELECT
rating,
COUNT(*) AS rating_count
FROM fact_swiggy_orders
GROUP BY rating
ORDER BY rating_count;
















