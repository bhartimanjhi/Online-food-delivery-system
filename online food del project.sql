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

-- Conditional Count: High value (> ₹500) & Low value (< ₹500) orders
select 
sum(case when order_total>500 then 1 else 0 end) as high_value_orders, 
sum(case when order_total<500 then 1 else 0 end) as low_value_orders
from (select o.order_id, sum(od.quantity*m.price) as order_total
from orders o 
join order_details od on o.order_id=od.order_id
join menu_item m on od.item_id=m.item_id
group by o.order_id) as order_summary;

-- Categorize Restaurants as Old or New Partner
select restaurant_id, rest_name, reg_date,
case 
when Year(reg_date)<2025 then 'old partner'
else 'new partner'
end as partner_type
from restaurant; 

-- Tag Items as Premium / Standard / Economy, f > 500 → Premium.If between 201–500 → Standard. If ≤ 200 → Economy
select item_id, item_name, price,
case 
when price>500 then 'premium'
when price between 201 and 500 then 'standard'
else 'economy'
end as tag_categories
from menu_item;

-- Reward Tier by Number of Orders (Gold / Silver / Bronze) ≥ 10 orders → Gold., Between 5 and 9 → Silver.,  Less than 5 → Bronze
select c.customer_id, c.customer_name, count(o.order_id) as total_orders,
case 
when count(o.order_id) >=10 then 'Gold'
when count(o.order_id) between 5 and 9 then 'Silver'
else 'Bronze'
end as rewardd_tier
from customers c 
left join orders o on c.customer_id=o.customer_id
group by c.customer_id, c.customer_name;

-- Classify Customers by Signup Year (Active / Moderate / Inactive)
select customer_id, customer_name, signup_date,
case
when year(signup_date)=2025 then 'Active'
when year(signup_date)=2024 then 'Moderate'
else 'Inactive'
end as customer_status
from customers;


-- Advanced queries:
-- First Order of each customer
select * 
from

(select order_id, customer_id, restaurant_id, order_date, row_number() over(partition by customer_id order by order_date) as r_n
from orders )as result
where r_n=1;

-- Top 2 most expensive items in each restaurant
select *
from 

(select restaurant_id, item_id, item_name, price , 
rank() over (partition by restaurant_id order by price desc) as rnk
from menu_item m ) as sub 
where  rnk<=2;

-- Find the Frequent diners using ntile
select customer_id, count(order_id) as total_orders,
ntile(4) over (order by count(order_id) desc)as quartile 
from orders
group by customer_id;

-- Assign a Serial Number to All Orders (in order of date)
select order_id, customer_id, restaurant_id, order_date,
row_number() over (order by order_date) as serial_number 
from orders; 

-- Get First Item in the Menu per Restaurant (alphabetically)
select * 
from 
(select item_id, restaurant_id, item_name, price,
row_number() over (partition by restaurant_id order by item_name) as rn
from menu_item) as ranked
where rn=1;

-- Total Number of Orders Each Customer Placed (without collapsing rows)
select o.order_id, o.customer_id, o.restaurant_id, o.order_date,
count(*) over (partition by o.customer_id) as total_orders_by_customer 
from orders o;

-- Restaurant with Highest Price Menu Item (1 per restaurant)
select 
restaurant_id,item_id, item_name, price 
from (select *, row_number() over (partition by restaurant_id order by price desc) as
rowno
from menu_item ) as ranked 
where rowno=1; 

--  Average Price of Items for Each Restaurant (compare each item to avg)
select restaurant_id, item_name, price, avg(price) over (partition by restaurant_id) as avg_price_per_restaurant 
from menu_item;

-- customer's last order date
select customer_id, order_id, max(order_date) over (partition by customer_id) as last_order_date
from orders;

-- same query using group by
select customer_id,order_id, max(order_date) as last_order_date
from orders
group by customer_id, order_id;

-- identify repeat customers( who have more than 1 order)
select * from 
(select customer_id, order_id, order_date, count(order_id) over (partition by customer_id) as total_orders
from orders) as sub
where total_orders>1;

-- same query using group by
select customer_id, count(order_id) as total_orders
from orders
group by customer_id
having count(order_id)>1;

-- Get previous and next item ordered by each customer
select customer_id, order_id, order_date,
lag(order_id) over(partition by customer_id order by order_date)as prev_order_id,
lead(order_id) over (partition by customer_id order by order_date)as next_order_id
from orders;

-- Previous Order Date for each customer
select customer_id, order_id, order_date,
lag(order_date) over(partition by customer_id order by order_date) as prev_order_date
from orders;

-- next Order Date for each customer
select customer_id, order_id, order_date,
lead(order_date) over(partition by customer_id order by order_date) as next_order_date
from orders;

-- Find the cheapest item per restaurant
select *
from
(select restaurant_id,item_name, price,
rank() over(partition by restaurant_id order by price asc) as price_rank
from menu_item) ranked_items
where price_rank=1;

-- Percentile Bucket for Customers (top/bottom tiers)
select customer_id,total_spend ,ntile(6) over(order by total_spend desc) as spend_bucket
from(
select o.customer_id, sum(od.quantity*m.price) 
over(partition by o.customer_id) as total_spend
from orders o
join order_details od on o.order_id=od.order_id
join menu_item m on od.item_id=m.item_id
)as buketed;

-- Rank Restaurants by Total Revenue (Without Gaps)
SELECT 
  restaurant_id,
  total_revenue,
  DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM (
  SELECT 
    o.restaurant_id,
    SUM(od.quantity * m.price) OVER (PARTITION BY o.restaurant_id) AS total_revenue
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  JOIN menu_item m ON od.item_id = m.item_id
) AS ranked;

-- customer total spend
create view customer_total_spend as 
select c.customer_id, c.customer_name, sum(m.price*od.quantity) as total_spend
from customers c
join orders o on o.customer_id =c.customer_id
join order_details od on o.order_id=od.order_id
join menu_item m on od.item_id=m.item_id
group by c.customer_id, c.customer_name;

-- filter customer- big spenders >1000
select * 
from customer_total_spend
where total_spend>1000
order by total_spend desc
limit 5;

-- customer_order_count
create view customer_order_count as 
select c.customer_id, c.customer_name, count(o.order_id) as total_orders
from customers c 
join orders o on o.customer_id=c.customer_id
group by c.customer_id, c.customer_name;

-- filter -frequent buyer>5
select *
from customer_order_count
where total_orders >5;

-- most_ordered_item
create view most_ordered_item as
select m.item_id, m.item_name, sum(od.quantity) as total_ordered_quantity
from menu_item m
join order_details od on m.item_id=od.item_id
group by m.item_id, m.item_name
order by total_ordered_quantity desc;

-- top 3 items
select *
from most_ordered_item
limit 3;

-- - Create a SQL view named avg_spend_per_order that displays each order's ID, the customer ID, and the total spend for that orde
create view avg_spend_per_order as
select o.order_id, o.customer_id, sum(od.quantity*m.price) as total_spend
from orders o
join order_details od on o.order_id=od.order_id
join menu_item m on m.item_id=od.item_id
group by o.order_id, o.customer_id;

-- find total_spend 3
select total_spend, avg(total_spend)
from avg_spend_per_order 
group by total_spend
limit 3;

-- - Create a SQL view named restaurant_performance that displays each restaurant's ID, name, total number of orders, and total revenue.
create view restaurant_performance as
select r.restaurant_id, r.rest_name, count(o.order_id) as total_orders,
sum(od.quantity*m.price) as total_revenue
from restaurant r
join orders o on o.restaurant_id=r.restaurant_id
join order_details od on o.order_id=od.order_id
join menu_item m on m.item_id=od.item_id
group by r.restaurant_id, r.rest_name;


select * 
from restaurant_performance;

-- - Create a SQL view named city_customer_spending that displays each city and the total amount spent by customers from that city.
create view city_customer_spending as
select c.customer_name, c.city, sum(od.quantity*m.price) as total_spend
from customers c
join orders o on c.customer_id=o.customer_id
join order_details od on o.order_id=od.order_id
join menu_item m on m.item_id=od.item_id
group by c.customer_name, c.city;

select * 
from city_customer_spending;

-- Create a SQL view named top_high_value_orders that displays the top 5 highest-value orders. The view should include the order ID, customer name, order date, and the total order value.
CREATE VIEW top_high_value_orders AS
SELECT 
    o.order_id,
    c.customer_name,
    o.order_date,
    SUM(oi.quantity * m.price) AS order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_details oi ON o.order_id = oi.order_id
join menu_item m on oi.item_id=m.item_id
GROUP BY o.order_id, c.customer_name, o.order_date
ORDER BY order_value DESC
LIMIT 5;
 
select * 
from top_high_value_orders;
 
 -- - Create a SQL view named customers_without_orders that lists all customers who have never placed an order. The view should include the customer ID, name, email, city, and signup date.
create view customers_without_orders as
select c.customer_id,c.customer_name, c.email, c.signup_date
from customers c
left join orders o on c.customer_id=o.customer_id
where o.order_id is NULL;

select *
from customers_without_orders;

-- temporary table 
-- top 3 customers (total_spending) using temporary table
create temporary table temp_total_spending as
select c.customer_id, c.customer_name, sum(m.price*od.quantity) as total_spent
from customers c
join orders o on c.customer_id=o.customer_id
join order_details od on o.order_id=od.order_id
join menu_item m on od.item_id=m.item_id
group by c.customer_id, c.customer_name;

select * 
from  temp_total_spending
order by total_spent desc
limit 3;

-- top 3 restaurant by revenue

create temporary table temp_restaurant_revenue as
select r.restaurant_id, r.rest_name, sum(m.price*od.quantity) as total_revenue
from restaurant r
join orders o on o.restaurant_id=r.restaurant_id
join order_details od on o.order_id=od.order_id
join menu_item m on m.item_id=od.item_id
group by r.restaurant_id, r.rest_name;

select *
from temp_restaurant_revenue
order by total_revenue desc
limit 3;

-- explore customers who ordered from 5+ different restaurants
create temporary table temp_customers_spent as
select o.customer_id, count(distinct o.restaurant_id) as distinct_rest
from orders o
group by o.customer_id;

select c.customer_id, c.customer_name, t.distinct_rest 
from temp_customers_spent t
join customers c on c.customer_id=t.customer_id
where t.distinct_rest >=5
order by t.distinct_rest desc, c.customer_name;

-- Customer Order Count
-- Goal:
-- Make a temporary table with each customer’s total number of orders. 
-- Then, show customers who have more than 2 orders.
create temporary table temp_customer_orders as 
select customer_id, count(order_id) as total_orders
from orders
group by customer_id;

select * 
from temp_customer_orders 
where total_orders >2;

-- Restaurant Revenue
-- Goal:
-- Create a temporary table with total revenue per restaurant.
-- Then, display restaurants where revenue is above ₹20,000.
create temporary table temp_totalrevenue_per_rest as
select o.restaurant_id, sum(od.quantity*m.price) as total_revenue
from orders o
join order_details od on o.order_id=od.order_id
join menu_item m on m.item_id=od.item_id
group by o.restaurant_id;

select * from temp_totalrevenue_per_rest
where total_revenue>20000;

-- High-Value Orders
-- Goal:
-- Make a temporary table with each order’s total value.
-- Then, show only orders above ₹1,000.
create temporary table temp_order_value as
select od.order_id, sum(od.quantity*m.price) as total_values
from order_details od
join menu_item m on m.item_id= od.item_id
group by od.order_id;

select *
from temp_order_value
where total_values>1000;

--  Popular Items
-- Goal:
-- Create a temporary table with total quantity sold per menu item.
-- Then, show the top 5 items by quantity.
create temporary table temp_item_sales as 
select od.item_id, m.item_name, sum(od.quantity) as total_quantity
from order_details od
join menu_item m on od.item_id=m.item_id
group by od.item_id, m.item_name;

select *
from temp_item_sales
order by total_quantity desc
limit 5;

-- “Big cart” orders: orders with 5+ items (quantity-wise)
-- Goal:
-- Find orders with 5+ items using a temp table of order item counts
create temporary table temp_cart_size as
select order_id, sum(quantity) as total_items
from order_details
group by order_id;

select *
from temp_cart_size
where total_items >=5;

-- CTE
-- Total orders per customers
with orders_per_customers as
( select o.customer_id, count(*) as total_orders
from orders o
group by o.customer_id)

select c.customer_name, opc.total_orders
from orders_per_customers opc
join customers c on opc.customer_id=c.customer_id
order by opc.total_orders desc;

-- first order date per customer
with first_order as 
(select o.customer_id,min(o.order_date) as first_order_date
from orders o 
group by o.customer_id)

select c.customer_name, f.first_order_date
from first_order f
join customers c on c.customer_id=f.customer_id
order by f.first_order_date;

-- number of menu items per restaurant
with item_per_rest as 
(select m.restaurant_id, count(*) as item_count
from menu_item m
group by m.restaurant_id)

select r.rest_name, ipr.item_count
from item_per_rest ipr
join restaurant r on r.restaurant_id=ipr.restaurant_id
order by ipr.item_count desc;

-- customers who ordered from more than 2 restaurants
with cust_rest_count as 
(select customer_id, count(distinct restaurant_id) as rest_count
from orders
group by customer_id)

select c.customer_id, c.customer_name, cr.rest_count
from cust_rest_count cr
join customers c on cr.customer_id=c.customer_id
where rest_count>2;

-- order placed on weekends
with weekend_orders as
(select order_id, order_date, dayofweek(order_date) as day_num
from orders)

select order_id, order_date
from weekend_orders 
where day_num in (1, 7);


-- cheapest item in each rest
with cheapest_mini_rest as 
(select restaurant_id, min(price) as mini_price
from menu_item
group by restaurant_id)

select m.item_name, ch.restaurant_id,r.rest_name, ch.mini_price
from cheapest_mini_rest ch
join menu_item m on m.restaurant_id=ch.restaurant_id
join restaurant r on m.restaurant_id=r.restaurant_id
order by mini_price; 


-- Top 5 most-sold items (by quantity)
with item_qty as
(select m.item_id,m.item_name, sum(od.quantity) as total_qty
from menu_item m
join order_details od on m.item_id=od.item_id
group by m.item_id,m.item_name)

select * 
from item_qty
order by total_qty desc 
limit 5;

-- Customers who never ordered
with active_customers as
(select distinct customer_id
from orders)
select c.customer_id, c.customer_name
from customers c
left join active_customers ac on c.customer_id=ac.customer_id
where ac.customer_id is NULL;

-- Active Customer List (Placed at Least One Order)
with active_customers as 
(select distinct customer_id 
from orders)
select c.customer_id, c.customer_name
from active_customers ac
join customers c on c.customer_id=ac.customer_id;

-- Items Sold Per Day (Quantity)
with day_items as
(select o.order_date as d, m.item_name, sum(od.quantity) as items_sold
from order_details od
join orders o on od.order_id=o.order_id
join menu_item m on m.item_id=od.item_id
group by o.order_date, m.item_name)
select *
from day_items
order by d;

-- Average Item Price Per Restaurant
with avg_price_per_rest as
(select r.restaurant_id, r.rest_name ,avg(m.price)
from menu_item m
join restaurant r on m.restaurant_id=r.restaurant_id
group by  r.restaurant_id, r.rest_name)
select *
from avg_price_per_rest;


-- Menu Items That Were Never Ordered
with items_never_ordered as
(select distinct item_id
from order_details od)
select m.item_id, m.item_name
from menu_item m
left join items_never_ordered oi on m.item_id=oi.item_id
where oi.item_id is NULL;

-- Orders With More Than 3 Items
with more_than_3qty as 
(select order_id, sum(quantity) as total_qty
from order_details
group by order_id)
select order_id, total_qty
from more_than_3qty 
where total_qty;

-- One-Time Customers
with cust_orders as
(select customer_id, count(order_id) as total_orders
from orders
group by customer_id)
select cu.*, c.customer_name
from cust_orders cu
join customers c on c.customer_id=cu.customer_id
where total_orders =1;

-- Restaurant Revenue Leaderboard
with revenue_rank as
(select o.restaurant_id, sum(m.price*od.quantity) as revenue
from order_details od
join menu_item m on od.item_id=m.item_id
join orders o on od.order_id=o.order_id
group by o.restaurant_id)
select r.rest_name, rr.revenue,
rank() over (order by rr.revenue desc) as revenue_rank
from revenue_rank rr
join restaurant r on rr.restaurant_id=r.restaurant_id;

--  Customers Who Ordered From More Than 3 Restaurants
with cust_rest_count as
(select customer_id, count(distinct restaurant_id) as restaurant_count
from orders 
group by customer_id)
select c.customer_name, crc.*
from cust_rest_count crc
join customers c on c.customer_id=crc.customer_id
where restaurant_count>3;


-- PROCEDURE
-- orders for a specific customer
delimiter //
create procedure orderbycustomer(in cust_id int)
begin
select * from orders where customer_id=cust_id;
end //
delimiter ;

call orderbycustomer(6);
call orderbycustomer(30);

-- customers in a specific city
delimiter //
create procedure customerbycity (in city_name varchar(5))
begin 
select * from customers
where city=city_name;
end //
delimiter //

call customerbycity('delhi');


-- best selling menu_items
DELIMITER //

CREATE PROCEDURE bestsellingitems(IN limit_num INT)
BEGIN
    SELECT m.item_name, SUM(od.quantity) AS total_sold
    FROM menu_item m
    JOIN order_details od ON m.item_id = od.item_id
    GROUP BY m.item_name
    ORDER BY total_sold DESC
    LIMIT limit_num;
END //

DELIMITER ;

CALL bestsellingitems(2);

-- Restaurants in a Specific City
Delimiter //
create procedure rest_specific_city(in city_name varchar(50))
begin
select restaurant_id, rest_name, city
from restaurant
where city = city_name;
end //
Delimiter ;

call rest_specific_city('Delhi');


-- Revenue Between Two Dates
Delimiter //
create procedure getrevenuebtwdates(in start_date date, in end_date date)
begin
select sum(m.price*od.quantity) as total_revenue
from orders o
join order_details od on od.order_id=od.order_id
join menu_item m on m.item_id=od.item_id
where o.order_date between start_date and end_date;
end //
Delimiter ;

-- Top N Customers by Orders
delimiter //
create procedure gettopcustomer(in limit_num int)
begin
select o.customer_id, c.customer_name, count(o.order_id) as total_orders
from orders o
join customers c on c.customer_id=o.customer_id
group by o.customer_id, c.customer_name
order by total_orders desc
limit limit_num;
end //
delimiter ;

-- Orders for a Specific Restaurant
delimiter //
create procedure specificrest(in rest_id int)
begin
select order_id, customer_id, restaurant_id, order_date
from orders
where restaurant_id = rest_id;
end //
delimiter ;

-- First Order Date for Each Customer
delimiter //
create procedure firstorderdateofcust()
begin
select customer_id, min(order_date) as first_order
from orders
group by customer_id;
end //
delimiter ;

-- Customer Signups Category
SELECT 
  customer_id,
  customer_name,
  signup_date,
  CASE 
    WHEN STR_TO_DATE(signup_date, '%d-%m-%Y') < '2024-01-01' THEN 'Early Bird'
    WHEN STR_TO_DATE(signup_date, '%d-%m-%Y') BETWEEN '2024-01-01' AND '2024-12-31' THEN 'Regular'
    ELSE 'New'
  END AS signup_category
FROM customers;

-- Customers with Max Orders
select o.customer_id, c.customer_name, count(*) as total_orders
from orders o
join customers c on o.customer_id=c.customer_id
group by o.customer_id, c.customer_name
having count(*) = (select max(order_count) from( select customer_id, count(*) as order_count
from orders
group by customer_id) as subquery
);

-- Menu Items Priced Above Global Average
select item_id, item_name, price
from menu_item
where price>(
select avg(price) 
from menu_item);

-- Restaurants With More Items Than Avg
select restaurant_id,count(*) as item_count
from menu_item
group by restaurant_id
having count(*)>(select avg(item_count) from (select restaurant_id, count(*) as item_count
from menu_item
group by restaurant_id) as avg_items);

-- Monthly Order Summary with >50 Orders
with monthly_orderss as (
select date_format(str_to_date(order_date, '%d-%m-%y'), '%y-%m') as month,
count(*) as total_orders
from orders
group by date_format(str_to_date(order_date, '%d-%m-%y'), '%y-%m')
)
select * from monthly_orderss
where total_orders>50;

-- Restaurant Size Category
select
m.restaurant_id, r.rest_name, count(m.item_id) as item_count,
case 
when count(m.item_id)<5 then 'small'
when count(m.item_id) between 5 and 10 then 'Medium' 
else 'Large'
end as size_category
from menu_item m 
join restaurant r on r.restaurant_id=m.restaurant_id
group by m.restaurant_id, r.rest_name;

-- Orders per Customer with Rank
with customer_orders as
(select customer_id, count(order_id) as total_orders
from orders 
group by customer_id)
select customer_id,
total_orders,
rank() over(order by total_orders desc)as order_rank 
from customer_orders;

select * 
from top_3_rests;

-- store orders from last 7 days
CREATE TEMPORARY TABLE recent_last_7_daysorders AS
SELECT *
FROM orders
WHERE order_date >= CURDATE() - INTERVAL 7 DAY;

select * 
from recent_last_7_daysorders;

-- Create View for Customer Spend
create view customer_spend as 
(select o.customer_id, sum(od.quantity*m.price)as total_spent
from orders o
join order_details od on o.order_id=od.order_id
join menu_item m on od.item_id=m.item_id
group by o.customer_id);

-- Average Order Value by City
SELECT order_values.city, AVG(order_values.total_order) AS avg_order_values
FROM (
  SELECT o.order_id, r.city, SUM(od.quantity*m.price) AS total_order
  FROM orders o 
  JOIN order_details od ON o.order_id=od.order_id
  JOIN menu_item m ON m.item_id=od.item_id
  JOIN restaurant r ON m.restaurant_id=r.restaurant_id 
  GROUP BY o.order_id, r.city
) AS order_values 
GROUP BY order_values.city
ORDER BY avg_order_values DESC;

-- Top 3 Restaurants by Revenue
create temporary table top_3_restaurants as
with revenue_per_restaurants as
(select m.restaurant_id,r.rest_name, sum(od.quantity*m.price)as total_revenue
from menu_item m
join order_details od on od.item_id=m.item_id
join restaurant r on m.restaurant_id=r.restaurant_id
group by m.restaurant_id,r.rest_name)
select * 
from ( select *, rank() over(order by total_revenue desc) as revenue_rank
from revenue_per_restaurants)
ranked where revenue_rank<=3;

select *
from  top_3_restaurants;
