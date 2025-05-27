--total amount each customer spends 
SELECT sales.customer_id,SUM(sales.product_id*menu.price) as payment
FROM dannys_diner.sales as sales 
INNER JOIN dannys_diner.menu as menu 
ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

-- how many days each customer visited 
SELECT customer_id,COUNT(order_date) FROM dannys_diner.sales
GROUP BY customer_id;

-- What was the first item from the menu purchased by each customer?
SELECT sales.customer_id, sales.product_id, menu.product_name, order_date FROM dannys_diner.sales as sales 
INNER JOIN dannys_diner.menu as menu
ON sales.product_id = menu.product_id
ORDER BY sales.order_date,sales.customer_id
LIMIT 5;

-- What is the most purchased item on the menu 
-- and how many times was it purchased by all customers?

SELECT menu.product_name,COUNT(sales.product_id) AS total_transaction FROM dannys_diner.sales as sales
INNER JOIN dannys_diner.menu as menu 
ON menu.product_id=sales.product_id
GROUP BY menu.product_name
ORDER BY total_transaction DESC;

-- Which item was the most popular for each customer?
-- A
SELECT menu.product_name, COUNT(menu.product_name) FROM dannys_diner.sales as sales
INNER JOIN dannys_diner.menu as menu 
ON menu.product_id = sales.product_id
WHERE sales.customer_id='A'
GROUP BY menu.product_name
ORDER BY COUNT(menu.product_name) DESC
LIMIT 1;
--B 
SELECT menu.product_name, COUNT(menu.product_name) FROM dannys_diner.sales as sales
INNER JOIN dannys_diner.menu as menu 
ON menu.product_id = sales.product_id
WHERE sales.customer_id='B'
GROUP BY menu.product_name
ORDER BY COUNT(menu.product_name) DESC
LIMIT 1;
--C
SELECT menu.product_name, COUNT(menu.product_name) FROM dannys_diner.sales as sales
INNER JOIN dannys_diner.menu as menu 
ON menu.product_id = sales.product_id
WHERE sales.customer_id='C'
GROUP BY menu.product_name
ORDER BY COUNT(menu.product_name) DESC
LIMIT 1;

-- Which item was purchased first by the customer after they became a member?
SELECT menu.product_name, sales.customer_id,members.join_date,sales.order_date
FROM dannys_diner.members as members
INNER JOIN dannys_diner.sales as sales
ON members.customer_id = sales.customer_id
INNER JOIN dannys_diner.menu as menu 
ON sales.product_id = menu.product_id
WHERE join_date <= order_date 
ORDER BY order_date ASC;

-- What is the total items and amount spent for each member before they became a member?
SELECT sales.customer_id,COUNT(sales.product_id),SUM(sales.product_id*menu.price) AS amount_spent 
FROM dannys_diner.sales as sales 
INNER JOIN dannys_diner.members as members 
ON sales.customer_id = members.customer_id
INNER JOIN dannys_diner.menu as menu 
on menu.product_id = sales.product_id
WHERE sales.order_date < members.join_date 
GROUP BY sales.customer_id;
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?

--POINTS ALLOCATION
CREATE TABLE dannys_diner.points AS (
SELECT sales.customer_id, 
 CASE
  WHEN menu.product_id = 1 THEN menu.price * 20
  ELSE menu.price * 10
  END AS points
 FROM dannys_diner.menu AS menu
INNER JOIN dannys_diner.sales ON 
sales.product_id = menu.product_id)

SELECT customer_id,SUM(points) FROM dannys_diner.points
GROUP BY customer_id;

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?
SELECT sales.customer_id, 
SUM(CASE WHEN sales.order_date <= 7 + members.join_date THEN menu.price*20 
	 ELSE menu.price * 10 END) AS points
FROM dannys_diner.members AS members 
INNER JOIN dannys_diner.sales AS sales 
ON members.customer_id = sales.customer_id
INNER JOIN dannys_diner.menu AS menu 
ON menu.product_id = sales.product_id
WHERE sales.order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY sales.customer_id;

-- A. Pizza Metrics
-- How many pizzas were ordered? 
  -- 14 pizzas
select count(order_id) from pizza_runner.customer_orders; 
-- How many unique customer orders were made? 
  --5 unique customer orders 
select count(distinct(customer_id)) from pizza_runner.customer_orders
-- How many successful orders were delivered by each runner?
  -- Runner_ID 1,2,3 all 1 order 
select runner_id,count(*) as successful_orders from pizza_runner.runner_orders 
where cancellation is  null 
group by runner_id

-- How many of each type of pizza was delivered?
  --Pizza_id 1: 4 
  --Pizza_id 2: 2 
select pizza_id,count(*) from pizza_runner.customer_orders as c  
inner join pizza_runner.runner_orders as r 
on c.order_id = r.order_id -- connecting order_id together 
where cancellation is null 
group by pizza_id;


-- How many Vegetarian and Meatlovers were ordered by each customer?
  -- Meatlovers: 10, Veg = 4 
select p.pizza_name,count(*) from pizza_runner.customer_orders as c 
inner join pizza_runner.pizza_names as p 
on p.pizza_id = c.pizza_id 
group by p.pizza_name;

-- What was the maximum number of pizzas delivered in a single order?
  -- Max 3 
select order_time,count(*) from pizza_runner.customer_orders 
group by order_time
order by count(*) desc
limit 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
  -- at least 1 change 
select customer_id,count(*) from pizza_runner.customer_orders 
where exclusions is not null or extras is not null 
group by customer_id;
  -- no changes: none 
select customer_id,count(*) from pizza_runner.customer_orders 
where exclusions is  null and  extras is null 
group by customer_id;
-- How many pizzas were delivered that had both exclusions and extras?
  -- 13 pizzas 
select count(*) from pizza_runner.customer_orders
where exclusions is not null and extras is not null 
-- What was the total volume of pizzas ordered for each hour of the day?
select extract(hour from order_time::time) as hour,count(*) from pizza_runner.customer_orders 
group by hour
order by hour;

-- What was the volume of orders for each day of the week?
select extract(dow from order_time) as week_num, count(*)
from pizza_runner.customer_orders
group by week_num
order by week_num


-- B. Runner and Customer Experience
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
    DATE_TRUNC('week', order_time::date) + INTERVAL '7 days' AS week_start,
    COUNT(*)
FROM pizza_runner.customer_orders
GROUP BY week_start
ORDER BY week_start;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

-- We’ll make use of the AGE function to extract the number of minutes from this interval. 
--One important thing to note is the order of inputs for this function - if you want positive outputs, you will need to put the more recent timestamp first!
WITH cte_pickup_minutes AS (
  SELECT DISTINCT
    t1.order_id,
    DATE_PART('minute', AGE(t1.pickup_time::TIMESTAMP,t2.order_time))::numeric AS pickup_minutes
  FROM pizza_runner.runner_orders AS t1
  INNER JOIN pizza_runner.customer_orders AS t2
    ON t1.order_id = t2.order_id
  WHERE t1.pickup_time != 'null'
)
SELECT
  ROUND(AVG(pickup_minutes), 3) AS avg_pickup_minutes
FROM cte_pickup_minutes;


-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
  -- order_id = 4 has 3 pizzas, order_id = 2 has 2 pizzas 
  
WITH cte_pickup_minutes AS (
  SELECT DISTINCT
    t1.order_id,
    DATE_PART('minute', AGE(t1.pickup_time::TIMESTAMP,t2.order_time))::numeric AS pickup_minutes
  FROM pizza_runner.runner_orders AS t1
  INNER JOIN pizza_runner.customer_orders AS t2
    ON t1.order_id = t2.order_id
  WHERE t1.pickup_time != 'null'
)
select co.order_id
  ,mi.pickup_minutes
  ,count(pizza_id) as num_pizza 
from pizza_runner.customer_orders as co
inner join cte_pickup_minutes as mi
on co.order_id = mi.order_id
group by 1,2
order by 3
;




select distance from pizza_runner.runner_orders limit 5;
-- What was the average distance travelled for each customer?

WITH cte_customer_order_distances AS (
SELECT DISTINCT
  t1.customer_id,
  t1.order_id,
  UNNEST(REGEXP_MATCH(t2.distance, '(^[0-9,.]+)'))::NUMERIC AS distance
FROM pizza_runner.customer_orders AS t1
INNER JOIN pizza_runner.runner_orders AS t2
  ON t1.order_id = t2.order_id
WHERE t2.pickup_time is not null
)
SELECT
  customer_id,
  ROUND(AVG(distance), 2) AS avg_distance
FROM cte_customer_order_distances
GROUP BY customer_id
ORDER BY customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?

WITH cte_durations AS (
  SELECT
    UNNEST(REGEXP_MATCH(duration, '(^[0-9]+)'))::NUMERIC AS duration
  FROM pizza_runner.runner_orders
  WHERE pickup_time is not null 
)
SELECT
  MAX(DURATION) - MIN(duration) AS max_difference
FROM cte_durations;



-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- speed = distance over time 
-- group by delivery (means group by order_id)

WITH cte_adjusted_runner_orders AS (
  SELECT
    runner_id,
    order_id,
    DATE_PART('minute', pickup_time::TIMESTAMP) AS hour_of_day,
    UNNEST(REGEXP_MATCH(distance, '(^[0-9,.]+)'))::NUMERIC AS distance,
    UNNEST(REGEXP_MATCH(duration, '(^[0-9]+)'))::NUMERIC AS duration
  FROM pizza_runner.runner_orders
  WHERE pickup_time != 'null'
)
SELECT
  runner_id,
  order_id,
  hour_of_day,
  distance,
  duration,
  ROUND(distance / (duration / 6), 1) AS avg_speed
FROM cte_adjusted_runner_orders;

-- What is the successful delivery percentage for each runner?


SELECT
  runner_id,
  ROUND(
    100 * SUM(CASE WHEN pickup_time != 'null' THEN 1 ELSE 0 END) /
    COUNT(*)
  ) AS success_percentage
FROM pizza_runner.runner_orders
GROUP BY runner_id
ORDER BY runner_id;

-- PART C 
-- What are the standard ingredients for each pizza?
with ptop as (
select 
  pr.pizza_id
  ,REGEXP_SPLIT_TO_TABLE(pr.toppings, '[,\s]+')::INTEGER topping 
from 
  pizza_runner.pizza_recipes as pr )
  
select 
  ptop.pizza_id
  ,STRING_AGG(pt.topping_name::TEXT, ',') AS standard_ingredients 
from 
  ptop 
inner join 
  pizza_runner.pizza_toppings as pt 
on ptop.topping = pt.topping_id 
group by 1; 

-- What was the most commonly added extra?

with extra_id as (
select 
  pizza_id
  ,regexp_split_to_table(extras , '[,\s]+')::integer es
from 
  pizza_runner.customer_orders
where 
  extras is not null and lower(extras) != 'null' and extras != '') 
  
select 
  pt.topping_name, count(pt.topping_name)
from 
  extra_id 
inner join pizza_runner.pizza_toppings as pt 
on pt.topping_id = extra_id.es
group by 1
order by 2;


-- What was the most common exclusion?

with ex_top as (select 
  regexp_split_to_table(exclusions,'[,\s]+')::integer as excluded 
  ,count(exclusions) as count_order 
from 
  pizza_runner.customer_orders as co 
where 
  exclusions is not null and exclusions != '' and  exclusions != 'null'
group by 
  exclusions
order by 
  count(exclusions) desc )
  
 
select 
  pt.topping_name, et.count_order 
from 
  ex_top as et 
inner join 
  pizza_runner.pizza_toppings as pt 
on pt.topping_id = et.excluded 
;

-- A. Pizza Metrics
-- How many pizzas were ordered? 
  -- 14 pizzas
select count(order_id) from pizza_runner.customer_orders; 
-- How many unique customer orders were made? 
  --5 unique customer orders 
select count(distinct(customer_id)) from pizza_runner.customer_orders
-- How many successful orders were delivered by each runner?
  -- Runner_ID 1,2,3 all 1 order 
select runner_id,count(*) as successful_orders from pizza_runner.runner_orders 
where cancellation is  null 
group by runner_id

-- How many of each type of pizza was delivered?
  --Pizza_id 1: 4 
  --Pizza_id 2: 2 
select pizza_id,count(*) from pizza_runner.customer_orders as c  
inner join pizza_runner.runner_orders as r 
on c.order_id = r.order_id -- connecting order_id together 
where cancellation is null 
group by pizza_id;


-- How many Vegetarian and Meatlovers were ordered by each customer?
  -- Meatlovers: 10, Veg = 4 
select p.pizza_name,count(*) from pizza_runner.customer_orders as c 
inner join pizza_runner.pizza_names as p 
on p.pizza_id = c.pizza_id 
group by p.pizza_name;

-- What was the maximum number of pizzas delivered in a single order?
  -- Max 3 
select order_time,count(*) from pizza_runner.customer_orders 
group by order_time
order by count(*) desc
limit 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
  -- at least 1 change 
select customer_id,count(*) from pizza_runner.customer_orders 
where exclusions is not null or extras is not null 
group by customer_id;
  -- no changes: none 
select customer_id,count(*) from pizza_runner.customer_orders 
where exclusions is  null and  extras is null 
group by customer_id;
-- How many pizzas were delivered that had both exclusions and extras?
  -- 13 pizzas 
select count(*) from pizza_runner.customer_orders
where exclusions is not null and extras is not null 
-- What was the total volume of pizzas ordered for each hour of the day?
select extract(hour from order_time::time) as hour,count(*) from pizza_runner.customer_orders 
group by hour
order by hour;

-- What was the volume of orders for each day of the week?
select extract(dow from order_time) as week_num, count(*)
from pizza_runner.customer_orders
group by week_num
order by week_num


-- B. Runner and Customer Experience
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
    DATE_TRUNC('week', order_time::date) + INTERVAL '7 days' AS week_start,
    COUNT(*)
FROM pizza_runner.customer_orders
GROUP BY week_start
ORDER BY week_start;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

-- We’ll make use of the AGE function to extract the number of minutes from this interval. 
--One important thing to note is the order of inputs for this function - if you want positive outputs, you will need to put the more recent timestamp first!
WITH cte_pickup_minutes AS (
  SELECT DISTINCT
    t1.order_id,
    DATE_PART('minute', AGE(t1.pickup_time::TIMESTAMP,t2.order_time))::numeric AS pickup_minutes
  FROM pizza_runner.runner_orders AS t1
  INNER JOIN pizza_runner.customer_orders AS t2
    ON t1.order_id = t2.order_id
  WHERE t1.pickup_time != 'null'
)
SELECT
  ROUND(AVG(pickup_minutes), 3) AS avg_pickup_minutes
FROM cte_pickup_minutes;


-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
  -- order_id = 4 has 3 pizzas, order_id = 2 has 2 pizzas 
  
WITH cte_pickup_minutes AS (
  SELECT DISTINCT
    t1.order_id,
    DATE_PART('minute', AGE(t1.pickup_time::TIMESTAMP,t2.order_time))::numeric AS pickup_minutes
  FROM pizza_runner.runner_orders AS t1
  INNER JOIN pizza_runner.customer_orders AS t2
    ON t1.order_id = t2.order_id
  WHERE t1.pickup_time != 'null'
)
select co.order_id
  ,mi.pickup_minutes
  ,count(pizza_id) as num_pizza 
from pizza_runner.customer_orders as co
inner join cte_pickup_minutes as mi
on co.order_id = mi.order_id
group by 1,2
order by 3
;




select distance from pizza_runner.runner_orders limit 5;
-- What was the average distance travelled for each customer?

WITH cte_customer_order_distances AS (
SELECT DISTINCT
  t1.customer_id,
  t1.order_id,
  UNNEST(REGEXP_MATCH(t2.distance, '(^[0-9,.]+)'))::NUMERIC AS distance
FROM pizza_runner.customer_orders AS t1
INNER JOIN pizza_runner.runner_orders AS t2
  ON t1.order_id = t2.order_id
WHERE t2.pickup_time is not null
)
SELECT
  customer_id,
  ROUND(AVG(distance), 2) AS avg_distance
FROM cte_customer_order_distances
GROUP BY customer_id
ORDER BY customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?

WITH cte_durations AS (
  SELECT
    UNNEST(REGEXP_MATCH(duration, '(^[0-9]+)'))::NUMERIC AS duration
  FROM pizza_runner.runner_orders
  WHERE pickup_time is not null 
)
SELECT
  MAX(DURATION) - MIN(duration) AS max_difference
FROM cte_durations;



-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- speed = distance over time 
-- group by delivery (means group by order_id)

WITH cte_adjusted_runner_orders AS (
  SELECT
    runner_id,
    order_id,
    DATE_PART('minute', pickup_time::TIMESTAMP) AS hour_of_day,
    UNNEST(REGEXP_MATCH(distance, '(^[0-9,.]+)'))::NUMERIC AS distance,
    UNNEST(REGEXP_MATCH(duration, '(^[0-9]+)'))::NUMERIC AS duration
  FROM pizza_runner.runner_orders
  WHERE pickup_time != 'null'
)
SELECT
  runner_id,
  order_id,
  hour_of_day,
  distance,
  duration,
  ROUND(distance / (duration / 6), 1) AS avg_speed
FROM cte_adjusted_runner_orders;

-- What is the successful delivery percentage for each runner?


SELECT
  runner_id,
  ROUND(
    100 * SUM(CASE WHEN pickup_time != 'null' THEN 1 ELSE 0 END) /
    COUNT(*)
  ) AS success_percentage
FROM pizza_runner.runner_orders
GROUP BY runner_id
ORDER BY runner_id;

-- PART C 
-- What are the standard ingredients for each pizza?
with ptop as (
select 
  pr.pizza_id
  ,REGEXP_SPLIT_TO_TABLE(pr.toppings, '[,\s]+')::INTEGER topping 
from 
  pizza_runner.pizza_recipes as pr )
  
select 
  ptop.pizza_id
  ,STRING_AGG(pt.topping_name::TEXT, ',') AS standard_ingredients 
from 
  ptop 
inner join 
  pizza_runner.pizza_toppings as pt 
on ptop.topping = pt.topping_id 
group by 1; 

-- What was the most commonly added extra?

with extra_id as (
select 
  pizza_id
  ,regexp_split_to_table(extras , '[,\s]+')::integer es
from 
  pizza_runner.customer_orders
where 
  extras is not null and lower(extras) != 'null' and extras != '') 
  
select 
  pt.topping_name, count(pt.topping_name)
from 
  extra_id 
inner join pizza_runner.pizza_toppings as pt 
on pt.topping_id = extra_id.es
group by 1
order by 2;


-- What was the most common exclusion?

with ex_top as (select 
  regexp_split_to_table(exclusions,'[,\s]+')::integer as excluded 
  ,count(exclusions) as count_order 
from 
  pizza_runner.customer_orders as co 
where 
  exclusions is not null and exclusions != '' and  exclusions != 'null'
group by 
  exclusions
order by 
  count(exclusions) desc )
  
 
select 
  pt.topping_name, et.count_order 
from 
  ex_top as et 
inner join 
  pizza_runner.pizza_toppings as pt 
on pt.topping_id = et.excluded 
;
