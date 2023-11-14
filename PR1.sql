/* DATA PREPRATION AND UNDERSTANDING 
Q1. WHAT IS THE TOTAL NO OF ROW IN  EACH OF THE 3 TABLES IN THE DATABSE */

SELECT (SELECT COUNT(*) FROM prod_cat_info) AS ProdCnt,
	   (SELECT COUNT(*) FROM customer) AS CustCnt,
       (SELECT COUNT(*) FROM transactions) AS transCnt
       
-- Q2. WHAT IS THE TOTAL NO OF TRANSECTION THAT HAVE A RETURN ?
SELECT COUNT(DISTINCT(transaction_id))
FROM transactions
Where Qty < 0 

/* Q3. As you would have noticed, the dates provided across the datasets are not in a correct format.
 As first steps, pls convert the date variables into valid date formats before proceeding ahead. */
 
select STR_TO_DATE(tran_date,'%d-%m-%Y') as trans_date
from transactions

 /* Q4. What is the time range of the transaction data available for analysis? Show the output in 
 number of days, months and years simultaneously in different columns. */
 SELECT
  TIMESTAMPDIFF(YEAR,MIN(STR_TO_DATE(tran_date,'%d-%m-%Y')),MAX(STR_TO_DATE(tran_date,'%d-%m-%Y'))) AS DIFF_YEARS ,
  TIMESTAMPDIFF(MONTH,MIN(STR_TO_DATE(tran_date,'%d-%m-%Y')),MAX(STR_TO_DATE(tran_date,'%d-%m-%Y'))) AS DIFF_MONTH ,
  TIMESTAMPDIFF(DAY,MIN(STR_TO_DATE(tran_date,'%d-%m-%Y')),MAX(STR_TO_DATE(tran_date,'%d-%m-%Y'))) AS DIFF_DAY
  from transactions
 
 -- Q5. Which product category does the sub-category “DIY” belong to?
 
 SELECT prod_cat , prod_subcat FROM prod_cat_info
 Where prod_subcat='DIY'


-- DATA ANALYSIS 

-- Q1. Which channel is most frequently used for transactions?
SELECT store_type ,count(*) AS most_frequently
from transactions
group by store_type
order by most_frequently DESC
LIMIT 1

-- Q2. What is the count of Male and Female customers in the database?
SELECT 
       (SELECT count(*) FROM customer WHERE Gender ='M') AS MALE ,
       (SELECT count(*) FROM customer WHERE Gender ='F') AS FEMALE
       
       
--     ONE MORE SOLUTION
/* SELECT Gender, COUNT(*) AS customer_count
FROM customer
where Gender IS NOT NULL
GROUP BY Gender */


-- Q3. From which city do we have the maximum number of customers and how many?

SELECT city_code, COUNT(*) AS customer_count
FROM customer
GROUP BY city_code
ORDER BY customer_count DESC
LIMIT 1


-- Q4. How many sub-categories are there under the Books category?
SELECT prod_cat, prod_subcat
FROM prod_cat_info
WHERE prod_cat = 'Books'

-- Q5. What is the maximum quantity of products ever ordered?
SELECT prod_cat_code ,MAX(Qty) AS max_ordered_quantity
FROM transactions
group by prod_cat_code

-- Q6. What is the net total revenue generated in categories Electronics and Books?

SELECT SUM(CAST(total_amt As DECIMAL(10,5))) AS total_revenue
from prod_cat_info as t1
join Transactions as t2
on t1.prod_cat_code = t2.prod_cat_code AND t1.prod_sub_cat_code=t2.prod_subcat_code
WHERE t1.prod_cat IN ('Electronics', 'Books')

-- Q7. How many customers have >10 transactions with us, excluding returns?
select count(*) as total_cust from (
SELECT cust_id, COUNT(DISTINCT(transaction_id)) AS transaction_count
FROM transactions
WHERE  qty > 0
GROUP BY cust_id
HAVING COUNT(DISTINCT(transaction_id)) > 10) as tans_count

-- Q8. What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?
SELECT SUM(CAST(total_amt As DECIMAL(10,5))) AS total_revenue
from prod_cat_info as t1
join Transactions as t2
on t1.prod_cat_code = t2.prod_cat_code AND t1.prod_sub_cat_code=t2.prod_subcat_code
WHERE prod_cat in('Clothing','Electronics')
AND store_type = 'Flagship store' 
AND qty>0

-- Q9. What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.
select prod_subcat ,SUM(CAST(total_amt As DECIMAL(10,5))) AS total_revenue from customer as t1
join transactions as t2
on t1.customer_Id=t2.cust_id
join prod_cat_info as t3
on t2.prod_cat_code=t3.prod_cat_code and t2.prod_subcat_code=t3.prod_sub_cat_code
where gender='M' AND prod_cat ='Electronics'
group by prod_subcat

-- Q10. What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?
SELECT prod_subcat, (sum(cast(total_amt as float))/(select sum(cast(total_amt as float)) as total_salse 
from Transactions 
where qty > 0 )) as persentage_salse
from prod_cat_info as t1
join Transactions as t2
on t1.prod_cat_code = t2.prod_cat_code AND t1.prod_sub_cat_code=t2.prod_subcat_code
where qty > 0
group by prod_subcat

-- Q11. For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers 
-- in last 30 days of transactions from max transaction date available in the data?
select cust_id ,TIMESTAMPDIFF(YEAR, dob,max_date) as age , revenue from (
select cust_id,dob,max(STR_TO_DATE(tran_date,'%d-%m-%Y')) as max_date,sum(cast(total_amt as float)) as revenue from customer as t1
join transactions as t2
on t1.customer_Id=t2.cust_id
where qty >0 
group by cust_id ,DOB)
as ta


-- Q12. Which product category has seen the max value of returns in the last 3 months of transactions?
select DATE_ADD(MONTH, 3,max(STR_TO_DATE(tran_date,'%d-%m-%Y'))) as cutoff_date
from transactions

SELECT DATE_ADD(
    (SELECT MAX(STR_TO_DATE(tran_date, '%d-%m-%Y')) FROM transactions),
    INTERVAL 3 MONTH
) AS cutoff_date;
GROUP BY prod_cat_code, STR_TO_DATE(tran_date,'%d-%m-%Y')


-- Q13. Which store-type sells the maximum products; by value of sales amount and by quantity sold?
SELECT store_type, SUM(Qty) AS total_quantity_sold, SUM(total_amt) AS total_sales_amount
FROM transactions
where qty > 0
GROUP BY store_type
ORDER BY total_quantity_sold , total_sales_amount 
DESC


-- Q14. What are the categories for which average revenue is above the overall average.
SELECT prod_cat_code , AVG(cast(total_amt as float)) AS avr_rev_cat
FROM transactions
where qty >0 
group by prod_cat_code
having AVG(cast(total_amt as float)) >= (select AVG(cast(total_amt as float)) FROM transactions where qty >0 )

-- Q15. Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.
WITH Top5Categories AS (
    SELECT prod_cat, SUM(quantity_sold) AS total_quantity
    FROM 
    GROUP BY category
    ORDER BY total_quantity DESC
    LIMIT 5
)
SELECT prod_subcat , AVG(total_amt) AS AVG_REV , sum(total_amt) AS tot_REV
FROM transactions
left join prod_cat_info ON prod_cat_info.prod_cat_code = transactions.prod_cat_code
GROUP BY prod_subcat

