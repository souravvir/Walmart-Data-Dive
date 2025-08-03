SELECT *FROM walmart;

-- DROP TABLE walmart;

--

SELECT COUNT(*) FROM walmart;

SELECT
	payment_method,
	COUNT(*)
FROM walmart
GROUP BY payment_method

SELECT 
	COUNT(DISTINCT branch)
	Branch
FROM walmart;

SELECT MAX(quantity) FROM walmart;

--Business Problems
-- #Q1. FInd different payment method and number of transaction, number of qty sold

SELECT
	payment_method,
	COUNT(*) as no_payments,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

-- #Q2. Identify the highest rated category each branch, displaying the branch, category

SELECT *
FROM (
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating, -- Comma added here
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM
        walmart
    GROUP BY
        1, 2
) AS ranked_data
WHERE
    rank = 1;

--#Q3. Identify the busiest day for eah branch based on the number of transactions

SELECT *
FROM (
    SELECT
        branch,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name, -- 1. Fixed TO_CHAR and added comma
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank -- 2. Removed extra comma
    FROM
        walmart
    GROUP BY
        1, 2
) AS daily_ranks
WHERE
    rank = 1;

	-- #Q4.  Calculate the total of items sold per payment method. list payment method and total quantity.
	
SELECT
	payment_method,
	-- COUNT(*) as no_payments,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

-- 
-- #Q5. 
-- determine the average, minimum and maximum rating of category for each city.
-- List the city, average_rating, min_rating and max_rating.
SELECT
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM
    walmart
GROUP BY
    1, 2;

-- 
-- #Q6.Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profit.

SELECT
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM
    walmart
GROUP BY
    category
ORDER BY
    total_profit DESC;


-- 
-- #Q7.
-- determine the most common payment method for each Branch.
-- Display Branch and the preferred_payment_method.

WITH cte
AS
	(SELECT
		branch,
		payment_method,
		COUNT(*) as total_trans,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	
	FROM walmart
	GROUP BY 1,2
	)
SELECT *
FROM cte
WHERE rank = 1

-- 
-- #Q8.
-- categories sales into 3 groups morning, afternoon, evening
-- find out which of the shift and number of invoices


SELECT
    branch,
    CASE
        WHEN EXTRACT(HOUR FROM time::TIME) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time::TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*)
FROM
    walmart
GROUP BY
    1, 2
ORDER BY
    1, 3 DESC;

-- 
-- #Q9.
-- identify 5 branch with highest decrease ratio in
-- reverse compare to lat year(current year 2023 and last year 2022)



-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM
        walmart
    WHERE
        EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY
        branch
),
revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM
        walmart
    WHERE
        EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY
        branch
)
SELECT
    ls.branch,
    ls.revenue AS revenue_2022,
    cs.revenue AS revenue_2023,
    ROUND(
        (ls.revenue - cs.revenue)::NUMERIC / ls.revenue::NUMERIC * 100,
        2
    ) AS decrease_ratio
FROM
    revenue_2022 AS ls
JOIN
    revenue_2023 AS cs ON ls.branch = cs.branch
WHERE
    ls.revenue > cs.revenue
ORDER BY
    decrease_ratio DESC
LIMIT 5;

SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
 