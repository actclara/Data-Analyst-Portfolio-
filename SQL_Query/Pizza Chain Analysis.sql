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