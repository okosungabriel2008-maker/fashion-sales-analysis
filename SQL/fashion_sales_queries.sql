select * from sales_data

select count(distinct(order_id)) from sales_data
select count(distinct(customer_id)) from sales_data
select count(distinct(product_id)) from sales_data

SELECT product_id, COUNT(*) AS occurrences
FROM health_data
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- CREATING ADDITIONAL VARIABLES SUCH AS
-- gross_sales
-- discount_amount
-- net_sales
-- month
-- quarter
-- season
-- average_order_value


ALTER TABLE sales_data
ADD COLUMN IF NOT EXISTS gross_sales NUMERIC(12,2),
ADD COLUMN IF NOT EXISTS discount_amount NUMERIC(12,2),
ADD COLUMN IF NOT EXISTS net_sales NUMERIC(12,2),
ADD COLUMN IF NOT EXISTS month TEXT,
ADD COLUMN IF NOT EXISTS quarter TEXT,
ADD COLUMN IF NOT EXISTS season TEXT,
ADD COLUMN IF NOT EXISTS average_order_value NUMERIC(12,2);

UPDATE sales_data
SET gross_sales = quantity * unit_price,
discount_amount = quantity * unit_price * COALESCE(discount, 0) / 100.0,
net_sales = quantity * unit_price - (quantity * unit_price * COALESCE(discount, 0) / 100.0);

UPDATE sales_data
SET month = TO_CHAR(order_date, 'FMMonth'),
quarter = 'Q' || EXTRACT(QUARTER FROM order_date)::INT, season = CASE
WHEN EXTRACT(MONTH FROM order_date) IN (4,5,6,7,8,9,10)
THEN 'Rainy'
ELSE 'Dry'
END;

UPDATE sales_data
SET average_order_value = (SELECT SUM(net_sales) / NULLIF(COUNT(DISTINCT order_id), 0)
FROM sales_data);

SELECT region, SUM(net_sales) / NULLIF(COUNT(DISTINCT order_id), 0) AS average_order_value
FROM sales_data
GROUP BY region
ORDER BY average_order_value DESC;

SELECT
    order_id,
    order_date,
    quantity,
    unit_price,
    discount,
    gross_sales,
    discount_amount,
    net_sales,
    month,
    quarter,
    season,
    average_order_value
FROM sales_data
LIMIT 10;



-- Product Performance

-- 1. Which product categories generate the highest revenue after discount?
SELECT category, SUM(quantity * unit_price * (1 - discount / 100.0)) AS net_revenue
FROM health_data
GROUP BY category
ORDER BY net_revenue DESC
limit 1;

-- 2. Which product categories have the highest number of units sold?
SELECT category, SUM(quantity) AS total_units_sold
FROM health_data
GROUP BY category
ORDER BY total_units_sold DESC
limit 1;

-- 3. Which products generate the highest revenue?
SELECT product_name, SUM(quantity * unit_price * (1 - discount / 100.0)) AS net_revenue
FROM health_data
GROUP BY product_name
ORDER BY net_revenue DESC
limit 1;

-- 4. Which products have the lowest sales performance?
SELECT product_name, SUM(quantity * unit_price * (1 - discount / 100.0)) AS net_revenue
FROM health_data
GROUP BY product_name
ORDER BY net_revenue 
limit 1;

-- 5. Which colors and sizes are most popular?
select color, sum(quantity) as most_color
from sales_data
group by color
order by most_color desc
limit 1;

select size, sum(quantity) as most_size
from sales_data
group by size
order by most_size desc
limit 1;

-- 6. Which products have high sales volume but relatively low revenue?
SELECT product_name, SUM(quantity) AS total_units_sold, SUM(quantity * unit_price) AS total_revenue
FROM health_data
GROUP BY product_name
ORDER BY total_units_sold DESC, total_revenue ASC
limit 10;

-- 7. Which products have high revenue but low sales volume?
SELECT product_name, SUM(quantity * unit_price) AS total_revenue, SUM(quantity) AS total_units_sold
FROM health_data
GROUP BY product_name
ORDER BY total_revenue DESC, total_units_sold ASC
limit 10;


-- Customer & Regional Performance:

-- 1. Which regions generate the highest revenue after discount?
SELECT region, SUM(quantity * unit_price * (1 - discount / 100.0)) AS net_revenue
FROM health_data
GROUP BY region
ORDER BY net_revenue DESC
limit 1;

-- 2. Which regions have the highest number of customers?
SELECT region, COUNT(DISTINCT customer_id) AS total_customers
FROM health_data
GROUP BY region
ORDER BY total_customers DESC;
limit 1;

-- 3. What is the average order value?
SELECT AVG(order_total) AS average_order_value
FROM (SELECT order_id, SUM(quantity * unit_price * (1 - discount / 100.0)) AS order_total
FROM health_data
GROUP BY order_id
) AS orders;

-- 4. Which customer groups contribute the most revenue?
SELECT gender, SUM(quantity * unit_price * (1 - discount / 100.0)) AS net_revenue
FROM health_data
GROUP BY gender
ORDER BY net_revenue DESC
limit 1;

-- 5. Do customers purchase more through online or physical stores?
SELECT payment_method, count(*) AS total_transctions
FROM sales_data
GROUP BY payment_method
ORDER BY total_transctions DESC
limit 1;

-- 6. Which sales channel generates the highest revenue?
SELECT payment_method, SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
FROM sales_data
GROUP BY payment_method
ORDER BY total_revenue DESC
limit 1;

-- 7. Are there significant differences in purchasing behavior across regions?
SELECT region, COUNT(*) AS total_purchases,
SUM(quantity) AS total_quantity_sold,
SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_discounted_revenue,
AVG(quantity * unit_price * (1 - discount / 100.0)) AS average_discounted_purchase_value
FROM sales_data
GROUP BY region
ORDER BY total_discounted_revenue DESC
limit 10;



