SELECT * FROM fsda-sql-01.grocery_dataset.categories
SELECT * FROM fsda-sql-01.grocery_dataset.cities
SELECT * FROM fsda-sql-01.grocery_dataset.countries
SELECT * FROM fsda-sql-01.grocery_dataset.customers
SELECT * FROM fsda-sql-01.grocery_dataset.employees
SELECT * FROM fsda-sql-01.grocery_dataset.products
limit 5
SELECT * FROM fsda-sql-01.grocery_dataset.sales
LIMIT 10

--no 1
SELECT
  c.categoryname
  , SUM (s.quantity * p.price * (1 - s.discount)) as total_revenue
FROM fsda-sql-01.grocery_dataset.sales s
JOIN fsda-sql-01.grocery_dataset.products p
  ON s.productid = p.productid
JOIN fsda-sql-01.grocery_dataset.categories c
  ON c.categoryid = p.categoryid
GROUP BY 1
ORDER BY 2 DESC

--no 2
SELECT
  c.categoryname
  , SUM (s.quantity) as total_unit_sold
  , SUM (s.quantity * p.price * (1 - s.discount)) as total_revenue
FROM fsda-sql-01.grocery_dataset.sales s
JOIN fsda-sql-01.grocery_dataset.products p
  ON s.productid = p.productid
JOIN fsda-sql-01.grocery_dataset.categories c
  ON p.categoryid = c.categoryid
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5

--no 3
SELECT
  c.categoryname
  , COUNT (DISTINCT s.customerid) as total_customers
  , SUM (s.quantity * p.price * (1 - s.discount)) as total_revenue
FROM fsda-sql-01.grocery_dataset.sales s
JOIN fsda-sql-01.grocery_dataset.products p
  ON s.productid = p.productid
JOIN fsda-sql-01.grocery_dataset.categories c
  ON p.categoryid = c.categoryid
GROUP BY 1
ORDER BY 3 desc

--no 4
SELECT
  c.categoryname
  , AVG(p.price) as avg_price_per_unit
FROM fsda-sql-01.grocery_dataset.products p
JOIN fsda-sql-01.grocery_dataset.categories c
  ON p.categoryid = c.categoryid
GROUP BY 1
ORDER BY 2 DESC

--no 5
SELECT
  c.categoryname
  , AVG(p.price) avg_price_per_unit
  , COUNT(DISTINCT s.customerid) total_customers
FROM fsda-sql-01.grocery_dataset.sales s
JOIN fsda-sql-01.grocery_dataset.products p
  ON s.productid = p.productid
JOIN fsda-sql-01.grocery_dataset.categories c
  ON p.categoryid = c.categoryid
GROUP BY 1
ORDER BY 2 DESC

--no 6
SELECT
  c.categoryname
  , SUM (s.quantity * p.price * (1 - s.discount)) total_revenue
  , SUM (s.quantity * p.price * (1 - s.discount)) / SUM (SUM (s.quantity * p.price * (1 - s.discount))) OVER () * 100 as revenue_percentage
FROM fsda-sql-01.grocery_dataset.sales s
JOIN fsda-sql-01.grocery_dataset.products p
  ON s.productid = p.productid
JOIN fsda-sql-01.grocery_dataset.categories c
 ON c.categoryid = p.categoryid
GROUP BY 1
ORDER BY 3 DESC

--no 7
WITH repeat_users AS (
SELECT
  p.categoryid
  , s.customerid
FROM `fsda-sql-01.grocery_dataset.sales` s
JOIN `fsda-sql-01.grocery_dataset.products` p
  ON s.productid = p.productid
GROUP BY p.categoryid, s.customerid
HAVING COUNT(*) > 1
),
total_users AS (
SELECT
  p.categoryid
  , COUNT(DISTINCT s.customerid) AS total_customers
FROM `fsda-sql-01.grocery_dataset.sales` s
JOIN `fsda-sql-01.grocery_dataset.products` p
  ON s.productid = p.productid
GROUP BY p.categoryid
)
SELECT
  c.categoryname
  , COUNT(DISTINCT r.customerid) AS repeat_customers
  , t.total_customers
  , COUNT(DISTINCT r.customerid) * 1.0 / t.total_customers AS repeat_purchase_rate
FROM total_users t
LEFT JOIN repeat_users r
    ON t.categoryid = r.categoryid
JOIN `fsda-sql-01.grocery_dataset.categories` c
    ON t.categoryid = c.categoryid
GROUP BY 1,3
ORDER BY 4 DESC
LIMIT 1

--no 9
WITH user_transaction AS (
SELECT
  customerid
  , SUM (p.price * s.quantity) AS total_transaction
FROM fsda-sql-01.grocery_dataset.sales s
JOIN fsda-sql-01.grocery_dataset.products p
  ON s.productid = p.productid
GROUP BY 1
),
ranked_user AS (
SELECT
  customerid
  , total_transaction
  , SUM (total_transaction) OVER (ORDER BY total_transaction DESC) AS cumulative_transaction
  , RANK () OVER (ORDER BY total_transaction DESC) AS rnk
FROM user_transaction
)
SELECT
  customerid
  , total_transaction
  , cumulative_transaction
FROM ranked_user
WHERE rnk = 1
ORDER BY 2 DESC
LIMIT 1

