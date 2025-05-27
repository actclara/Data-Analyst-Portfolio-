-- How many customers has Foodie-Fi ever had?

select 
  count(distinct(customer_id))
from foodie_fi.subscriptions;
-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
select 
  date_trunc('month',start_date) as month 
  ,count(plan_id) as trial_count 
from foodie_fi.subscriptions
where plan_id = 0 
group by 1
order by month ;
-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select
  p.plan_name 
  ,count(s.plan_id) as count_plan
from foodie_fi.subscriptions as s 
inner join 
  foodie_fi.plans as p 
on s.plan_id = p.plan_id
where s.start_date>date('2020-12-31')
group by 1

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select 
 sum(case when plan_id = 4 then 1 else 0 end) as churned
 ,round(sum(case when plan_id = 4 then 1 else 0 end)::numeric/count(distinct customer_id)*100,2)as total_customer 
from foodie_fi.subscriptions 
-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
with rank_cte as (select 
 customer_id
 ,plan_id 
 ,start_date 
 ,row_number() over(partition by customer_id order by start_date asc) as rank_plan
from foodie_fi.subscriptions )

select 
 sum(case when plan_id = 4 then 1 else 0 end) as churn_count
 ,round(sum(case when plan_id = 4 then 1 else 0 end)/sum(count(distinct customer_id)) over() * 100 ,2) as percent_churn
from rank_cte
where rank_plan = 2 -- filter what comes after trial which is rank 1, then rank 2 must be churn 


-- What is the number and percentage of customer plans after their initial free trial?
with rank_cte as (select 
 customer_id
 ,plan_id
 ,start_date
 ,row_number() over(partition by customer_id order by start_date asc) as rank_plans
from foodie_fi.subscriptions) 

select 
 plan_id 
 ,count(distinct(customer_id)) count_sub
 , round(count(distinct(customer_id))/sum(count (distinct customer_id)) over()*100,2) as percent_total
from rank_cte
where rank_plans = 2 
group by 1 

-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

with rank_cte as (select 
 customer_id
 ,plan_id 
 ,start_date
 ,row_number() over(partition by customer_id order by start_date desc) as rank_plan
from foodie_fi.subscriptions 
where start_date <= date('2020-12-31') ) 
select 
 plan_id
 ,count(distinct customer_id) as current_plan 
 ,round(count(distinct customer_id)/sum(count (distinct customer_id)) over ()  *100,2) as total
from rank_cte 
where rank_plan = 1 
group by 1 

-- How many customers have upgraded to an annual plan in 2020?
with cte_plan as (
select 
 ffs.customer_id as c_id 
 ,fp.plan_name as pn
 ,row_number() over(partition by customer_id order by start_date desc) as rank_plan 
from foodie_fi.subscriptions as ffs 
inner join foodie_fi.plans as fp
on ffs.plan_id = fp.plan_id 
where start_date <=date('2020-12-31') ) 

select 
 sum(case when pn = 'pro annual' then 1 else 0 end) as pro_count 
from cte_plan 
where rank_plan = 1 

-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

with cte_pro as (select 
 customer_id
 ,start_date
 ,sum(case when plan_id = 3 then 1 else 0 end) as day_pro 
 ,sum(case when plan_id = 0 then 1 else 0 end) as day_join
 ,row_number() over(partition by customer_id order by start_date desc) as rank_plan
from foodie_fi.subscriptions
group by 1,2) 
,
cte_one as (
select 
	customer_id
	,start_date
from cte_pro 
where day_pro = 1)
,
cte_two as (
select 
	customer_id
	,start_date
from cte_pro 
where day_join = 1) 


select 
	avg(date_trunc('min',c1.start_date::timestamp-c2.start_date::timestamp)) as duration 
from cte_one as c1
left join cte_two as c2 
on c1.customer_id = c2.customer_id


-- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
SELECT
  30 * (annual_days.duration / 10) || ' - ' || 30 * (annual_days.duration / 10) || ' days' AS breakdown_period
  ,COUNT(*) AS customers
FROM annual_days
GROUP BY breakdown_period, annual_days.duration
ORDER BY annual_days.duration;


-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
with cte_dw as (select 
 customer_id
 ,start_date
 ,plan_id
 ,lag(plan_id) over(partition by start_date order by start_date desc) as lag_plan_id
from foodie_fi.subscriptions
where start_date <=date('2020-12-31')
group by 1,2,3) 

-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

-- from 2 to 1 
WITH ranked_plans AS (
SELECT
  customer_id,
  plan_id,
  start_date,
  LAG(plan_id) OVER (
      PARTITION BY start_date
      ORDER BY start_date DESC
  ) AS lag_plan_id
FROM foodie_fi.subscriptions
WHERE DATE_PART('year', start_date) = 2020
)
SELECT
  COUNT(distinct(customer_id))
FROM ranked_plans
WHERE lag_plan_id = 2 AND plan_id = 1;

-- first generate the lead plans as above
-- Step 1: filtering out the year and trial plan 
WITH lead_plans AS (
SELECT
  customer_id,
  plan_id,
  start_date,
  LEAD(plan_id) OVER (
      PARTITION BY customer_id
      ORDER BY start_date
    ) AS lead_plan_id,
  LEAD(start_date) OVER (
      PARTITION BY customer_id
      ORDER BY start_date
    ) AS lead_start_date
FROM foodie_fi.subscriptions
WHERE DATE_PART('year', start_date) = 2020
AND plan_id != 0
),
-- case 1: non churn monthly customers
-- Using the Date_Part function to find out how many times need to add +1 month 
-- for customers who do not churn
-- Also not taking into account churned customers and pro_annual subs
case_1 AS (
SELECT
  customer_id,
  plan_id,
  start_date,
  DATE_PART('mon', AGE('2020-12-31'::DATE, start_date))::INTEGER AS month_diff
FROM lead_plans
WHERE lead_plan_id is null
-- not churn and annual customers
AND plan_id NOT IN (3, 4)
),
-- generate a series to add the months to each start_date
-- this is the part where you add the month_diff to the start_date so this
-- adds the rows 
case_1_payments AS (
  SELECT
    customer_id,
    plan_id,
    (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
  FROM case_1
),
-- case 2: churn customers
--- do the same for the churn accounts only 
case_2 AS (
  SELECT
    customer_id,
    plan_id,
    start_date,
    DATE_PART('mon', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff
  FROM lead_plans
  -- churn accounts only
  WHERE lead_plan_id = 4
),
case_2_payments AS (
  SELECT
    customer_id,
    plan_id,
    (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
  from case_2
),
-- case 3: customers who move from basic to pro plans
-- we subtract by 1 because we want to have the months where customers
-- are sticking to their first plan before moving to the next
case_3 AS (
  SELECT
    customer_id,
    plan_id,
    start_date,
    DATE_PART('mon', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff
  FROM lead_plans
  WHERE plan_id = 1 AND lead_plan_id IN (2, 3)
),
case_3_payments AS (
  SELECT
    customer_id,
    plan_id,
    (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
  from case_3
),
-- case 4: pro monthly customers who move up to annual plans
case_4 AS (
  SELECT
    customer_id,
    plan_id,
    start_date,
    DATE_PART('mon', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff
  FROM lead_plans
  WHERE plan_id = 2 AND lead_plan_id = 3
),
case_4_payments AS (
  SELECT
    customer_id,
    plan_id,
    (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
  from case_4
),
-- case 5: annual pro payments
case_5_payments AS (
  SELECT
    customer_id,
    plan_id,
    start_date
  FROM lead_plans
  WHERE plan_id = 3
),
-- union all where we union all parts
union_output AS (
  SELECT * FROM case_1_payments
)
SELECT
  customer_id,
  plans.plan_id,
  plans.plan_name,
  start_date AS payment_date,
  -- price deductions are applied here
  CASE
    WHEN union_output.plan_id IN (2, 3) AND
      LAG(union_output.plan_id) OVER w = 1
    THEN plans.price - 9.90
    ELSE plans.price
    END AS amount,
  RANK() OVER w AS payment_order
FROM union_output
INNER JOIN foodie_fi.plans
  ON union_output.plan_id = plans.plan_id
-- where filter for outputs for testing
WHERE customer_id IN (1, 2, 7, 11, 13, 15, 16, 18, 19, 25, 39)
WINDOW w AS (
  PARTITION BY union_output.plan_id
  ORDER BY start_date
);

