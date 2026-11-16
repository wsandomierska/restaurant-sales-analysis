-- Restaurant Sales & Menu Performance | Q1 2023
-- Source: Maven Analytics - Restaurant Orders
-- Dialect: MySQL
-- Grain: one row per order detail; one order may contain several items.
-- Missing product IDs are retained for order counts. Revenue and AOV
-- use known prices only and may underestimate actual sales.

USE restaurant_db;

-- 1. Sales overview and data quality
SELECT
    COUNT(*) AS total_order_records,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(mi.menu_item_id) AS items_sold,
    COUNT(CASE WHEN od.item_id IS NULL THEN 1 END) AS missing_item_ids,
    ROUND(SUM(mi.price), 2) AS total_revenue,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value,
    ROUND(COUNT(*) / COUNT(DISTINCT od.order_id), 2) AS avg_records_per_order,
    ROUND(COUNT(mi.menu_item_id) / COUNT(DISTINCT od.order_id), 2) AS avg_identified_items_per_order
FROM order_details od
LEFT JOIN menu_items mi ON mi.menu_item_id = od.item_id;

-- 2. Menu composition and listed prices by category
SELECT
    category,
    COUNT(item_name) AS number_of_dishes,
    ROUND(AVG(price), 2) AS avg_price,
    MAX(price) AS max_price,
    MIN(price) AS min_price
FROM menu_items
GROUP BY category
ORDER BY avg_price DESC;

-- 3. Top 10 menu items by sales volume
SELECT
    mi.item_name,
    mi.category,
    COUNT(od.order_details_id) AS items_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue
FROM menu_items mi
INNER JOIN order_details od ON mi.menu_item_id = od.item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category
ORDER BY items_sold DESC, mi.item_name
LIMIT 10;

-- 4. Top 10 menu items by revenue
SELECT
    mi.item_name,
    mi.category,
    COUNT(od.order_details_id) AS items_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue
FROM menu_items mi
INNER JOIN order_details od ON mi.menu_item_id = od.item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category
ORDER BY total_revenue DESC, mi.item_name
LIMIT 10;

-- 5. Category performance (average price weighted by sales volume)
SELECT
    mi.category,
    ROUND(AVG(mi.price), 2) AS avg_item_sold_price,
    COUNT(od.order_details_id) AS items_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue
FROM menu_items mi
INNER JOIN order_details od ON mi.menu_item_id = od.item_id
GROUP BY mi.category
ORDER BY total_revenue DESC;

-- 6. Monthly sales performance
SELECT
    DATE_FORMAT(od.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(mi.menu_item_id) AS items_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value
FROM order_details od
LEFT JOIN menu_items mi ON mi.menu_item_id = od.item_id
GROUP BY DATE_FORMAT(od.order_date, '%Y-%m')
ORDER BY order_month;

-- 7. Weekday performance and average revenue per observed date
SELECT
    DAYNAME(od.order_date) AS day_of_week,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(mi.menu_item_id) AS items_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value,
    COUNT(DISTINCT od.order_date) AS number_of_days,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_date), 2) AS avg_daily_revenue
FROM order_details od
LEFT JOIN menu_items mi ON mi.menu_item_id = od.item_id
GROUP BY DAYNAME(od.order_date)
ORDER BY avg_daily_revenue DESC;

-- 8. Hourly sales performance
SELECT
    HOUR(od.order_time) AS order_hour,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(mi.menu_item_id) AS items_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value
FROM order_details od
LEFT JOIN menu_items mi ON mi.menu_item_id = od.item_id
GROUP BY HOUR(od.order_time)
ORDER BY order_hour;
