use online_food_del;

-- restaurant located in delhi
SELECT 
    rest_name, city
FROM
    restaurant
WHERE
    city = 'Delhi';

-- 3 most expensive food items
SELECT 
    item_name, price
FROM
    menu_item
ORDER BY price DESC
LIMIT 3;

-- list all order ids where quantity is greater than 2
SELECT 
    order_id, quantity
FROM
    order_details
WHERE
    quantity > 2;

-- show the orders along with rest name
SELECT 
    o.order_id, r.rest_name
FROM
    orders o
        JOIN
    restaurant r ON o.restaurant_id = r.restaurant_id;

-- show customer names and order dates for orders placed in january 2023
SELECT 
    c.customer_name, o.order_date
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
WHERE
    o.order_date BETWEEN '2023-01-01' AND '2023-01-31';

-- List all customers along with their city who placed an order on or after '2023-01-01'
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date
FROM
    customers c
        JOIN
    orders o ON o.customer_id = c.customer_id
WHERE
    o.order_date >= '2023-01-01';

-- Show restaurant names and order IDs for orders placed from restaurants in Mumbai
SELECT 
    r.rest_name, o.order_id
FROM
    restaurant r
        JOIN
    orders o ON o.restaurant_id = r.restaurant_id
WHERE
    r.city = 'Mumbai';

-- Customers who have ordered from a specific restaurant – ‘Spice Villa'
select c.customer_id, c.customer_name, r.rest_name
from customers c
join orders o on o.customer_id=c.customer_id
join restaurant r on r.restaurant_id=o.restaurant_id
where r.rest_name='Golden table';

-- Number of Unique Customers per City
select count(distinct customer_id), city
from customers
group by city;

-- Most Frequently Ordered Items
select item_name, count(item_id)
from menu_item
group by item_name
order by count(item_id) desc
limit 10;


-- Restaurants with Low Order Counts (< 30) 
select rest_name, count(restaurant_id)
from restaurant 
group by rest_name
having count(restaurant_id) <30
order by count(restaurant_id) asc ;


-- Total Customers, Restaurants, Orders
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_restaurants FROM restaurant;
SELECT COUNT(*) AS total_orders FROM orders;

-- Unique Customers per City
SELECT city, COUNT(DISTINCT customer_id) AS unique_customers
FROM customers
GROUP BY city;

-- Metro vs Non-Metro Orders

SELECT 
  CASE WHEN city IN ('Mumbai', 'Delhi') THEN 'Metro' ELSE 'Non-Metro' END AS city_type,
  COUNT(*) AS total_orders
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY city_type;


-- List customers who placed more than 3 orders
select o.customer_id, c.customer_name, count(o.order_id) as total_orders
from orders o 
join customers c on o.customer_id=c.customer_id
group by o.customer_id, c.customer_name
having count(o.order_id)>3; 

-- Display menu items that were ordered more than 2 times
select i.item_id, count(od.item_id) as total_items, i.price
from order_details od
join menu_item i on i.item_id=od.item_id
group by i.item_id, i.price 
having count(od.item_id)>2; 

-- Find categories where the average item price is greater than ₹300
select item_name, avg(price) avg_price 
from menu_item
group by item_name 
having avg(price)>300;

-- top five spending customers
select c.customer_id, c.customer_name, sum(m.price*od.quantity) as total_spent
from orders o
join customers c on o.customer_id=c.customer_id
join order_details od on o.order_id=od.order_id
join menu_item m on od.item_id=m.item_id
group by o.customer_id, c.customer_name
order by sum(m.price*od.quantity) desc
limit 5;

-- restaurant-wise Order Count
select count(o.order_id) as order_count, r.restaurant_id, r.rest_name
from orders o
join restaurant r on r.restaurant_id=o.restaurant_id
group by r.restaurant_id,r.rest_name
order by restaurant_id; 

-- Average Order Value by City
select order_values.city, avg(order_values.total_order) avg_order_values
from ( select o.order_id, r.city, sum(od.quantity*m.price) as total_order
from orders o 
join order_details od on o.order_id=od.order_id
join menu_item m on m.item_id=od.item_id
join restaurant r on m.restaurant_id=r.restaurant_id 
group by o.order_id, r.city ) as order_values 
group by order_values.city
order by avg_order_values desc; 

-- RESTAURANT INSIGHTS
-- Top 3 Revenue-Generating Restaurants

SELECT 
    r.rest_name, SUM(m.price * od.quantity) AS total_revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    menu_item m ON m.item_id = od.item_id
        JOIN
    restaurant r ON o.restaurant_id = r.restaurant_id
GROUP BY r.rest_name
ORDER BY total_revenue DESC
LIMIT 3;

-- Average Quantity per Restaurant

SELECT r.rest_name, AVG(od.quantity) AS avg_order_qty
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
GROUP BY r.rest_name;

-- Restaurant Partner Category

SELECT rest_name, 
CASE 
  WHEN YEAR(reg_date) > 2025 THEN 'New Partner'
  ELSE 'Old Partner'
END AS partner_category
FROM restaurant;

-- CUSTOMER INSIGHTS
-- Top 5 Customers by Total Orders

SELECT c.customer_name, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_orders DESC
LIMIT 5;

-- Customer Reward Tiers (Gold/Silver/Bronze)

SELECT c.customer_name, COUNT(o.order_id) AS total_orders,
CASE 
  WHEN COUNT(o.order_id) >= 10 THEN 'Gold'
  WHEN COUNT(o.order_id) BETWEEN 5 AND 9 THEN 'Silver'
  ELSE 'Bronze'
END AS tier
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

-- Customer Activity by Signup Year

SELECT customer_name, signup_date,
CASE 
  WHEN YEAR(signup_date)=2025 THEN 'Active'
  WHEN YEAR(signup_date)=2024 THEN 'Moderate'
  ELSE 'Inactive'
END AS signup_status
FROM customers;

-- MENU & ORDER INSIGHTS
-- Top 3 Most Frequently Ordered Items

SELECT m.item_name, COUNT(od.item_id) AS total_orders
FROM order_details od 
JOIN menu_item m ON m.item_id = od.item_id
GROUP BY m.item_name 
ORDER BY total_orders DESC
LIMIT 3;

-- Item Price Category

SELECT item_name, price,
CASE 
  WHEN price > 500 THEN 'Premium'
  WHEN price BETWEEN 201 AND 500 THEN 'Standard'
  ELSE 'Economy'
END AS category
FROM menu_item;

-- High vs Low Value Orders

WITH order_totals AS (
  SELECT 
    o.order_id,
    SUM(m.price * od.quantity) AS total_amount
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  JOIN menu_item m ON od.item_id = m.item_id
  GROUP BY o.order_id
)
SELECT 
  CASE 
    WHEN total_amount > 500 THEN 'High Value'
    WHEN total_amount < 500 THEN 'Low Value'
    ELSE 'Medium Value'
  END AS order_type,
  COUNT(*) AS total_orders
FROM order_totals
GROUP BY order_type;



-- LOCATION INSIGHTS
-- Orders by City

SELECT c.city, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY total_orders DESC;

-- Top Restaurants per City

SELECT r.city, r.rest_name, COUNT(o.order_id) AS total_orders
FROM restaurant r
JOIN orders o ON o.restaurant_id = r.restaurant_id
GROUP BY r.city, r.rest_name
ORDER BY r.city, total_orders DESC;

-- Customers Who Haven’t Placed Any Order
SELECT 
    c.customer_id, 
    c.customer_name, 
    c.city
FROM 
    customers c
WHERE 
    c.customer_id NOT IN (SELECT DISTINCT customer_id FROM orders)
ORDER BY 
    c.customer_id;

-- Orders Placed in January 2023
SELECT 
    c.customer_id, 
    c.customer_name, 
    o.order_id, 
    o.order_date
FROM 
    customers c
JOIN 
    orders o 
ON 
    c.customer_id = o.customer_id
WHERE 
    o.order_date BETWEEN '2023-01-01' AND '2023-01-31'
ORDER BY 
    o.order_date;

-- Citywise Customer Pairs (Same City)
SELECT 
    a.customer_name AS customer_1,
    b.customer_name AS customer_2,
    a.city
FROM 
    customers a
JOIN 
    customers b 
ON 
    a.city = b.city 
    AND a.customer_id < b.customer_id
ORDER BY 
    a.city, customer_1, customer_2;

-- 1. Get the top 5 customers based on total orders placed.
SELECT 
    c.customer_name,
    c.customer_id,
    COUNT(o.order_id) AS totalorders
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name , c.customer_id
ORDER BY totalorders DESC
LIMIT 5;
-- how customer names and the restaurants they ordered from
select c.customer_name, r.rest_name 
from customers c 
join orders o on c.customer_id = o.customer_id
join restaurant r on o.restaurant_id=r.restaurant_id;

--  List all customers and their orders (if any)
select c.customer_name, o.order_id 
from customers c
left join orders o on c.customer_id=o.customer_id;

-- List all restaurants and who ordered from them (if any)
select r.rest_name, c.customer_name, o.order_id
from restaurant r 
right join orders o on o.restaurant_id=r.restaurant_id
right join customers c on o.customer_id=c.customer_id;

-- Show all customers and restaurants, even if no orders exist
-- Customers and their orders (if any)
SELECT c.customer_name, r.rest_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN restaurant r ON o.restaurant_id = r.restaurant_id

UNION

-- Restaurants and their orders (if any)
SELECT c.customer_name, r.rest_name, o.order_id
FROM restaurant r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
LEFT JOIN customers c ON o.customer_id = c.customer_id;

-- Find customers from the same city
select a.customer_name a1 , b.customer_name as b1, a.city
from customers a
join customers b on a.city=b.city and a.customer_id<>b.customer_id;

--  Which restaurant has served the highest number of unique customers
select r.rest_name, r.restaurant_id, count(distinct o.customer_id) as uniquec
from restaurant r 
join orders o on r.restaurant_id = o.restaurant_id
group by r.rest_name, r.restaurant_id
order by uniquec desc
limit 1;

-- top 3 restaurants who generated more revenue
select r.rest_name, sum(m.price*od.quantity) as total_revenue
from restaurant r 
join menu_item m on r.restaurant_id=m.restaurant_id
join order_details od on od.item_id=m.item_id
group by r.rest_name
order by total_revenue desc 
limit 3;

-- Find top 3 most frequently ordered items.
select m.item_name, count(od.item_id) as orders
from order_details od 
join menu_item m on m.item_id = od.item_id
group by m.item_name 
order by orders desc
limit 3;

-- Get list of customers who have placed more than 3 orders.
select c.customer_id, c.customer_name, count(o.order_id) as total_orders 
from orders o 
join customers c on o.customer_id=c.customer_id
group by c.customer_id, c.customer_name
having total_orders > 3;

--  Average Quantity per Order per Restaurant 
SELECT 
    o.restaurant_id, r.rest_name, AVG(od.quantity) AS avg_orders
FROM
    orders o
        JOIN
    order_details od ON od.order_id = o.order_id
        JOIN
    restaurant r ON o.restaurant_id = r.restaurant_id
GROUP BY o.restaurant_id , r.rest_name;

-- List customers and the restaurants they’ve ordered from more than once
select c.customer_id, c.customer_name, r.rest_name, count(o.order_id) as total_orders
from orders o 
join restaurant r on o.restaurant_id=r.restaurant_id
join customers c on o.customer_id=c.customer_id
group by c.customer_id, c.customer_name, r.rest_name
having total_orders>1;

-- Identify the top 3 revenue-generating restaurants
select r.restaurant_id, r.rest_name, sum(m.price*od.quantity) as total_revenue
from orders o
join order_details od on o.order_id=od.order_id
join menu_item m on m.item_id=od.item_id
join restaurant r on o.restaurant_id=r.restaurant_id
group by r.restaurant_id, r.rest_name
order by total_revenue desc
limit 3; 

-- tag customers based on city non-metro or metro
select customer_id, customer_name, city, 
case 
when city='Mumbai' then  'Metro_city'
when city='Delhi' then 'Metro_city'
else
'non-metro_city'
end as citytype from customers;

-- Count Orders Placed by Metro vs Non-Metro Customers
select case 
when city in ('Mumbai', 'Delhi') then 'metro'
else 'Non_metro'
end
as citytype, count(*) from orders o
join customers c on c.customer_id=o.customer_id
group by case 
when city in ('Mumbai', 'Delhi') then 'metro'
else 'Non_metro'
end;


-- -- conditional Count – How Many High Value Orders (ABOVE ₹500) & low value orders (BELOW ₹500) 
select m.item_name, 
sum(m.price*od.quantity) as total_orders,
case
when sum(m.price*od.quantity)>500 then 'high value'
when sum(m.price*od.quantity)<500 then 'low value'
else 'exact 500'
end as item_values
from orders o 
join order_details od on o.order_id=od.order_id
join menu_item m on m.item_id=od.item_id
group by m.item_name; 


-- Categorize Restaurants Based on Year of Registration as an old or new partner (BEFORE 2025 AS OLD PARTNER) 
select rest_name, restaurant_id, reg_date,
case 
when year(reg_date) >2025 then 'new partner'
else 'old partner'
end as category 
from restaurant;

--  Tag Items as Premium / Standard / Economy
select item_name, price,
case 
when price>500 then 'premium'
when price between 201 and 500 then 'standard' -- when  201<price< 500 then 'standard'
when price<=200 then 'Economy'
else 'item is item'
end 
as item_values
from menu_item;

-- — Reward Tier by Number of Orders (Gold / Silver / Bronze)
SELECT 
    c.customer_id,
    c.customer_name,
    count(o.order_id) as total_orders, 
case 
when count(o.order_id) >= 10 then 'Gold'
when count(o.order_id) between 5 and 9 then 'silver'
else 'Bronze'
end 
as tiers
from customers c
left join orders o on c.customer_id=o.customer_id
group by c.customer_id, c.customer_name;



--  Classify Customers by Signup Year (Active / Moderate / Inactive)
select customer_id, customer_name, signup_date ,
case 
when year(signup_date)=2025 then 'Active'
when year(signup_date)=2024 then 'Moderate'
else 'Inactive'
end 
as signuptype
from customers;

-- show all items of menu, price along with the average price of all items
select item_name, price, (select avg(price) from menu_item) as avg_price
from menu_item;

-- show customers who placed atleast one order
select customer_id, customer_name, (select count(order_id) from orders) as total__orders
from customers 
where (select count(order_id) from orders) >=1;
-- or 
select customer_name, customer_id
from customers
where customer_id in (select customer_id from orders);

-- Show each food item and how much more it costs than the average
select item_id, item_name, price, (select avg(price) from menu_item) as avg_price ,price-(select avg(price) from menu_item) as avg_price_difference
from menu_item;

-- List food items that cost more than the average price
select item_id, item_name,price, (select avg(price) from menu_item) avg_price
from menu_item
where price>(select avg(price) from menu_item);

--  Show customers who haven’t placed any orders
SELECT customer_id, customer_name 
from customers
where customer_id not in(SELECT customer_id FROM orders) order by customer_id desc;

