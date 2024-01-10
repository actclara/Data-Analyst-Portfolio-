CREATE TABLE amazon.sales_data
(product_id text,
product_name text,
category text,
discounted_price text,
actual_price text,
discount_percentage text,
rating text,
rating_count text,
about_product text,
user_id text,
user_name text,
review_id text,
review_title text,
review_content text,
img_link text,
product_link text);

-- DATA CLEANING PART I 
-- removing symbols such as currency and percentage
-- changing data type according to the value 
UPDATE amazon.sales_data
SET discounted_price = REPLACE(discounted_price,'₹',''),
    actual_price = REPLACE(actual_price,'₹',''),
    discount_percentage = REPLACE(discount_percentage,'%',''),
	rating_count = REPLACE(rating_count,',','')
WHERE discount_percentage LIKE '%\%%'
    OR actual_price LIKE '₹%'
    OR discounted_price LIKE '₹%'
	OR rating_count LIKE '%,%'
	;
	

UPDATE amazon.sales_data
SET actual_price = REPLACE(actual_price,',',''),
	discounted_price=REPLACE(discounted_price,',',''),
WHERE actual_price LIKE '%,%'
	OR discounted_price LIKE '%,%';
	
select rating from amazon.sales_data
where rating like '%|%';

UPDATE amazon.sales_data 
SET rating = REPLACE(rating,'|','0')
WHERE rating LIKE '%|%'

alter table amazon.sales_data 
alter column product_id type varchar, 
alter column discounted_price type numeric
using discounted_price::numeric, 
alter column actual_price type numeric
using actual_price::numeric, 
alter column discount_percentage type numeric
using discount_percentage::numeric, 
alter column rating type numeric
using rating::numeric, 
alter column rating_count type numeric
using rating_count::numeric;

select * from amazon.sales_data limit 5;


-- DATA CLEANING PART 2 
-- checking if there are any null values 
DO $$
DECLARE
    col_name TEXT;
    query_text TEXT;
    result INTEGER;
BEGIN
    FOR col_name IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = 'sales_data' AND table_schema = 'amazon'
    LOOP
        query_text := 'SELECT COUNT(*) FROM amazon.sales_data WHERE ' || col_name || ' IS NULL';
        EXECUTE query_text INTO result;
        RAISE NOTICE 'Column % has % NULL values', col_name, result;
    END LOOP;
END $$;

-- Find out which rows have a null rating_count 
select * from amazon.sales_data where rating_count is null;

-- replace the null value in rating_count 
UPDATE amazon.sales_data 
SET rating_count = COALESCE(rating_count,null,0)
WHERE rating_count is null;

select * from amazon.sales_data where rating_count = 0;



-- checking for any duplicate values 
select product_id,count(*) from amazon.sales_data
group by product_id
having count(*) >1
;

select * from amazon.sales_data
where product_id  = 'B008FWZGSG'

select * from amazon.sales_data
where product_id  = 'B09MQSCJQ1'



WITH duplicates_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY product_id,product_name,category,discounted_price,actual_price
							 ,discount_percentage,rating,rating_count,about_product,user_id,user_name,review_id,
							 review_title,review_content,img_link,product_link) AS rn
    FROM amazon.sales_data
)
SELECT *
FROM duplicates_cte
WHERE rn > 1;



-- Build category hierarchy
-- 1. split by the delimiter '|'
-- 2. rename the categories into several subcategories 
-- 3. split the tables? 
select * from amazon.sales_data limit 5;

-- Max delimiter occurrence: 6 
SELECT 
    MAX(LENGTH(category) - LENGTH(REPLACE(category, '|', ''))) AS delimiter_count
FROM amazon.sales_data;

-- Building the hierarchical categories 
create table amazon.category_level 
(
main_category  text,
second_category  text,
third_category  text,
fourth_category  text,
fifth_category  text,
sixth_category   text);

-- Investigating the main categories at Amazon rating reviews 
select distinct(main_category) from amazon.category_level;


-- Min and Max Rating Value (0-5)
select max(rating), min(rating) from amazon.sales_data;


-- which category gave the highest discount_percentage on average 

DROP VIEW IF EXISTS sales_summary;
CREATE VIEW  sales_summary AS (
select product_id as product_id,
	   rating, 
	   rating_count,
	   discount_percentage,
	   discounted_price,
	   split_part(category,'|',1) as main_category, 
	   split_part(category,'|',2) as second_category,
	   split_part(category,'|',3) as third_category, 
	   split_part(category,'|',4) as fourth_category,
	   split_part(category,'|',5) as fifth_category, 
	   split_part(category,'|',6) as sixth_category
from amazon.sales_data); 

-- creating a new table to compile summary of main category products
CREATE TABLE amazon.main_category_result  (id SERIAL PRIMARY KEY, main_category text, discount_percent numeric(10,2) )

insert into amazon.main_category_result(main_category,discount_percent)
select main_category,round(avg(discount_percentage),2) as discount_percent from sales_summary
group by main_category;




-- Count number of products based on main_category
-- Conclusion: most of the products reviewed are electronics followed by computers and accessories 
alter table amazon.main_category_result
add column num_reviewed numeric

-- insert this to the main_category_result
 

with rating_num as (
select main_category,sum(rating_count) as num_reviewed from sales_summary
group by main_category
)

--select * from amazon.main_category_result as m 
--full outer join rating_num as r on 
--r.main_category = m.main_category 


UPDATE amazon.main_category_result AS m 
SET num_reviewed = COALESCE(r.num_reviewed, 0) 
-- Replace new_column with the name of the new column in main_category_result
FROM rating_num AS r
WHERE m.main_category = r.main_category;

select * FROM amazon.main_category_result;


-- which category has the highest and worst rating 

alter table amazon.main_category_result 
add column average_rating numeric;

-- Conclusion: Office Products followed by Toys & Games have the highest average rating 

with aver as (select main_category, round(avg(rating),2) as average_rating from sales_summary
group by main_category
)


UPDATE amazon.main_category_result AS m 
SET average_rating = COALESCE(a.average_rating, 0) 
-- Replace new_column with the name of the new column in main_category_result
FROM aver AS a
WHERE m.main_category = a.main_category;



-- total revenue : 4578580 rupee 
select sum(discounted_price) from amazon.sales_data;

-- total revenue by main category 
alter table amazon.main_category_result
add column revenue_total numeric;

-- Conclusion: Electronics highest contributor to the revenue_sum 
with rev_sum as (select main_category,sum(discounted_price) as revenue_sum from sales_summary
group by main_category
order by revenue_sum desc)

update amazon.main_category_result as m 
set revenue_total = coalesce(r.revenue_sum,0)
from rev_sum as r 
where m.main_category=r.main_category



-- Figure out which specific electronics category is most popular: Smart Televisions 
select main_category,second_category,third_category,fourth_category,sum(discounted_price) as revenue_sum from sales_summary
group by main_category,second_category,third_category,fourth_category
order by revenue_sum desc; 

-- Average rating of Smart Televisions: 4.21 
select fourth_category,round(avg(rating),2) from sales_summary
where fourth_category='SmartTelevisions'
group by fourth_category


-- Summary results of the main category of Amazon sales
select * from amazon.main_category_result;



