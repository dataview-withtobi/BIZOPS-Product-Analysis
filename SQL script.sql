--
# import dataset for bizops csv files into 'maka' database using table data import wizard in mysql
# assess csv data files to study the tables and observe which column names are shared across the tables
--
SELECT * FROM orders;
SELECT * FROM ordered_products;
SELECT * FROM product_details;
SELECT * FROM payments;
SELECT * FROM reviews;
SELECT * FROM customers;
--
# order_id is the primary key, product_id and customer_id, foreign keys
--
# Order metrics by month
SELECT monthname(STR_TO_DATE(order_purchase_timestamp, '%m/%d/%Y')) AS month,
	ROUND(SUM(order_item_id * price)) AS revenue
FROM orders o
JOIN ordered_products op
ON o.order_id = op.order_id
GROUP BY 1 ORDER BY 2 DESC;
# this shows May had the highest revenue followed by April
# September having the lowest revenue due to the fact that data included does not cover the whole of september
--
# Average number of days for order delivery
SELECT AVG(TIMESTAMPDIFF(day,STR_TO_DATE(order_purchase_timestamp, '%m/%d/%Y'),STR_TO_DATE(order_estimated_delivery_date, '%m/%d/%Y'))) AS avg_delivery_days
FROM orders;
# The result shows it takes an average of 23 to 24 days to deliver ordered products
--
# Total revenue = price of goods by quantity
SELECT SUM(sold) as Total_revenue
FROM
(SELECT order_item_id * price as sold
FROM ordered_products) quantity_sold ;
# This shows that total revenue is '8372807.91'
--
# Total items sold
SELECT SUM(order_item_id) AS items_sold
FROM ordered_products;
# Total items sold is '73639'
--
# average freight value 
SELECT (AVG(freight_value)) AS Avg_freight_value
FROM ordered_products;
# average freight value of orders is '20.47'
--
# Look into order metrics, i'll join necessary columns from orders and ordered_products that answer our questions
SELECT o.order_id, 
	o.order_status, 
	o.order_purchase_timestamp, 
	o.order_estimated_delivery_date,
    op.order_item_id, op.price, op.freight_value
FROM orders o
JOIN ordered_products op
ON o.order_id = op. order_id;
--
# Let's look into the order status
SELECT DISTINCT order_status, COUNT(*) AS total
FROM
(
SELECT o.order_id, 
	o.order_status, 
	o.order_purchase_timestamp, 
	o.order_estimated_delivery_date,
    op.order_item_id, op.price, op.freight_value
FROM orders o
JOIN ordered_products op
ON o.order_id = op. order_id) as order_metrics
GROUP BY 1
ORDER BY 2 DESC;
--
# Product metrics
SELECT MAX(product_weight_g)  as max_prod_weight_g,
	MIN(product_weight_g)  as min_prod_weight_g,
    AVG(product_weight_g) as AVG_prod_weight_g
FROM product_details;
# This query showed that max product weight was 40425g and minimum weight 0g with an average of 2276.95g product weight
--
# photo quantity attached to products
SELECT DISTINCT product_photos_qty, COUNT(*) AS photos_count
FROM product_details
GROUP BY 1 ORDER BY 2 DESC;
# This shows that most product attached a minimum of 1 photo 
--
# states which this business should invest more marketing
# Let's see how many states we have
Select count(distinct customer_state) as no_states
from customers;
# we have 27 states
--
# states which this business should invest more marketing 
--
SELECT DISTINCT c.customer_state, COUNT(op.order_id) total_order,
ROUND(SUM(op.order_item_id * op.price)) as total_revenue
FROM orders o
JOIN ordered_products op
ON o.order_id = op.order_id
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY 1 ORDER BY 3 DESC;
# the result shows that states SP, RJ, MG, PR had the highest number of orders and total revenue respectively..
# Investors will be assured of continued order requests and return on investment 
-- 
# Sellers that should be delisted from this platform
SELECT op.seller_id, 
	r.review_score,
	COUNT(o.order_status) AS cancellation_rates
FROM ordered_products op
JOIN reviews r
ON op.order_id = r.order_id
JOIN orders o
ON o.order_id = r.order_id
WHERE review_score = 1 AND order_status = 'canceled'
GROUP BY 1
LIMIT 3;
# The result shows that these sellers have products with the highest cancellation rates(2) and a one of the lowest review scores. 