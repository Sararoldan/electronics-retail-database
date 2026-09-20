CREATE DATABASE ELECTRONICS_RETAIL_DB;
USE ELECTRONICS_RETAIL_DB;

# CREATE EMPTY TABLES
CREATE TABLE segment (
	segment_id INT NOT NULL,
    segment_name VARCHAR(25) NOT NULL,
    PRIMARY KEY (segment_id));
    
    
CREATE TABLE country (  
    country_id INT NOT NULL,
    country VARCHAR(45) NOT NULL,
    iso3 VARCHAR(45) NOT NULL,
    market VARCHAR(45) NOT NULL, 
    region VARCHAR(45) NOT NULL,
    PRIMARY KEY (country_id));

    
CREATE TABLE location (
	location_id INT NOT NULL,
    city VARCHAR(45) NOT NULL,
    state VARCHAR(45) NOT NULL,
    country_id INT NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    PRIMARY KEY (location_id),
    FOREIGN KEY (country_id) REFERENCES country(country_id) ON UPDATE CASCADE ON DELETE CASCADE);


CREATE TABLE customer (
    customer_id VARCHAR(25) NOT NULL,
    customer_first_name VARCHAR(45) NOT NULL,
    customer_last_name VARCHAR(45) NOT NULL,
    segment_id INT NOT NULL,
    location_id INT NOT NULL,
    PRIMARY KEY (customer_id),
    FOREIGN KEY (segment_id) REFERENCES segment(segment_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES location(location_id) ON UPDATE CASCADE ON DELETE CASCADE);
 
 
CREATE TABLE  orders (
	order_id VARCHAR(25) NOT NULL,
    order_date DATETIME NOT NULL,
    customer_id VARCHAR(25) NOT NULL,
    PRIMARY KEY (order_id),
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON UPDATE CASCADE ON DELETE CASCADE);
   
   
CREATE TABLE  shipping (
	shipping_id int NOT NULL,
    order_id VARCHAR(25) NOT NULL,
    ship_date DATETIME NOT NULL,
    ship_mode VARCHAR(25) NOT NULL,
    PRIMARY KEY (shipping_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON UPDATE CASCADE ON DELETE CASCADE);


CREATE TABLE  category (
	category_id INT NOT NULL,
    category_name VARCHAR(25) NOT NULL,
	PRIMARY KEY (category_id));  
    
    
CREATE TABLE  sub_category (
	sub_category_id INT NOT NULL,
    sub_category_name VARCHAR(25) NOT NULL,
    category_id INT NOT NULL,
	PRIMARY KEY (sub_category_id),  
    FOREIGN KEY (category_id ) REFERENCES category (category_id ) ON UPDATE CASCADE ON DELETE CASCADE);
   
   
CREATE TABLE  product (
	product_id VARCHAR(25) NOT NULL,
    product_name VARCHAR(25) NOT NULL,
    sub_category_id INT NOT NULL,
	PRIMARY KEY (product_id),
	FOREIGN KEY (sub_category_id) REFERENCES sub_category(sub_category_id) ON UPDATE CASCADE ON DELETE CASCADE);
    
    
CREATE TABLE order_line (
    order_line_id INT NOT NULL,
    order_id VARCHAR(25) NOT NULL,
    product_id VARCHAR(25) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
	quantity INT NOT NULL,
    discount DECIMAL(4,2) NOT NULL,
	sales DECIMAL(10,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_line_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE CASCADE);
    
    
CREATE TABLE order_cost (
    cost_id INT NOT NULL,
    order_line_id INT NOT NULL,
    shipping_costs DECIMAL(10,2) NOT NULL,
    storage_costs DECIMAL(10,2) NOT NULL,
	labor_costs DECIMAL(10,2) NOT NULL,
	selling_costs DECIMAL(10,2) NOT NULL,
	purchasing_costs DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (cost_id),
    FOREIGN KEY (order_line_id) REFERENCES order_line(order_line_id) ON UPDATE CASCADE ON DELETE CASCADE);
    
INSERT IGNORE INTO segment (segment_id, segment_name)
SELECT DISTINCT segment_id, segment
FROM data_electronics;

INSERT IGNORE INTO country (country_id, country, iso3, market, region)
SELECT DISTINCT country_id, country, iso3, market, region
FROM data_electronics;

INSERT IGNORE INTO location 
(location_id, city, state, country_id, latitude, longitude)
SELECT DISTINCT location_id, city, state, country_id, latitude, longitude
FROM data_electronics;

# FOR INSERT I USED WIZARD DATA IMPORT OPTION

INSERT IGNORE INTO customer
(customer_id, customer_first_name, customer_last_name, segment_id, location_id)
SELECT DISTINCT 
customer_id, customer_first_name, customer_last_name, segment_id, location_id
FROM data_electronics;

INSERT IGNORE INTO category (category_id, category_name)
SELECT DISTINCT category_id, category_name
FROM data_electronics;  

INSERT IGNORE INTO sub_category
(sub_category_id, sub_category_name, category_id)
SELECT DISTINCT sub_category_id, sub_category_name, category_id
FROM data_electronics;

INSERT IGNORE INTO product
(product_id, product_name, sub_category_id)
SELECT DISTINCT 
    product_id,
    product_name,
    sub_category_id
FROM data_electronics;
 
INSERT IGNORE INTO orders
(order_id, order_date, customer_id)
SELECT DISTINCT
    order_id,
    order_date,
    customer_id
FROM data_electronics;
 
 
 
INSERT IGNORE INTO shipping
(shipping_id, order_id, ship_date, ship_mode)
SELECT DISTINCT
    shipping_id,
    order_id,
    ship_date,
    ship_mode
FROM data_electronics;


INSERT IGNORE INTO order_line
(order_line_id, order_id, product_id, unit_price, quantity, discount, sales, profit)
SELECT DISTINCT
    order_line_id,
    order_id,
    product_id,
    CAST(unit_price AS DECIMAL(10,2)),
    quantity,
    CAST(discount AS DECIMAL(5,4)),
    sales,
    profit
FROM data_electronics;



INSERT IGNORE INTO order_cost
(cost_id, order_line_id, shipping_costs, storage_costs, labor_costs, selling_costs, purchasing_costs)
SELECT DISTINCT
    cost_id,
    order_line_id,
    ROUND(shipping_costs, 2),
    ROUND(storage_costs, 2),
    ROUND(labor_costs, 2),
    ROUND(selling_costs, 2),
    ROUND(purchasing_costs, 2)
FROM data_electronics;

# 1. QUERY EXAMPLE
# TOP 10 CUSTOMER WITH THE HIGHEST TOTAL SPENDING

SELECT 
    c.customer_id,
    CONCAT(c.customer_first_name, ' ', c.customer_last_name) AS customer_name,
    SUM(ol.sales) AS total_spent
FROM order_line ol
JOIN orders o ON ol.order_id = o.order_id
JOIN customer c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spent DESC
LIMIT 10;

# 2.QUERY EXAMPLE
# TOP 10 PRODUCTS WITH CATEGORY AND SUBCATEGORY
SELECT 
    p.product_name,
    sc.sub_category_name,
    c.category_name,
    SUM(ol.sales) AS total_sales
FROM order_line ol
JOIN product p ON ol.product_id = p.product_id
JOIN sub_category sc ON p.sub_category_id = sc.sub_category_id
JOIN category c ON sc.category_id = c.category_id
GROUP BY p.product_name, sc.sub_category_name, c.category_name
ORDER BY total_sales DESC
LIMIT 10;

ALTER TABLE country
ADD CONSTRAINT chk_iso3_length
CHECK (CHAR_LENGTH(iso3) = 3);

ALTER TABLE order_line
ADD CONSTRAINT chk_quantity
CHECK (quantity > 0);

ALTER TABLE shipping
ADD CONSTRAINT chk_ship_mode
CHECK (ship_mode IN ('Basic', 'Standard', 'Prime', 'Express')),
ADD CONSTRAINT chk_ship_date
CHECK (ship_date >= '2019-01-01');

