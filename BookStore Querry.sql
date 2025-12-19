DROP TABLE IF EXISTS ORDERS;

DROP TABLE IF EXISTS CUSTOMERS;

DROP TABLE IF EXISTS BOOKS;

CREATE TABLE BOOKS (
	BOOK_ID SERIAL PRIMARY KEY,
	TITLE VARCHAR(100),
	AUTHOR VARCHAR(100),
	GENRE VARCHAR(50),
	PUBLISHED_YEAR INT,
	PRICE NUMERIC(10, 2),
	STOCK INT
);

CREATE TABLE CUSTOMERS (
	CUSTOMER_ID SERIAL PRIMARY KEY,
	NAME VARCHAR(100),
	EMAIL VARCHAR(100),
	PHONE VARCHAR(15),
	CITY VARCHAR(50),
	COUNTRY VARCHAR(150)
);

CREATE TABLE ORDERS (
	ORDER_ID SERIAL PRIMARY KEY,
	CUSTOMER_ID INT REFERENCES CUSTOMERS (CUSTOMER_ID),
	BOOK_ID INT REFERENCES BOOKS (BOOK_ID),
	ORDER_DATE DATE,
	QUANTITY INT,
	TOTAL_AMOUNT NUMERIC(10, 2)
);

SELECT
	*
FROM
	BOOKS;

SELECT
	*
FROM
	CUSTOMERS;

SELECT
	*
FROM
	ORDERS;

COPY BOOKS (
	BOOK_ID,
	TITLE,
	AUTHOR,
	GENRE,
	PUBLISHED_YEAR,
	PRICE,
	STOCK
)
FROM
	'C:\Program Files\PostgreSQL\18\data\Aaditya aggarwal\Books.csv' CSV HEADER;

COPY CUSTOMERS (CUSTOMER_ID, NAME, EMAIL, PHONE, CITY, COUNTRY)
FROM
	'C:\Program Files\PostgreSQL\18\data\Aaditya aggarwal\Customers.csv' CSV HEADER;

COPY ORDERS (
	ORDER_ID,
	CUSTOMER_ID,
	BOOK_ID,
	ORDER_DATE,
	QUANTITY,
	TOTAL_AMOUNT
)
FROM
	'C:\Program Files\PostgreSQL\18\data\Aaditya aggarwal\Orders.csv' CSV HEADER;

-- 1) Retrieve all books in the "Fiction" genre:
SELECT
	*
FROM
	BOOKS
WHERE
	GENRE = 'Fiction';

-- 2) Find books published after the year 1950:
SELECT
	*
FROM
	BOOKS
WHERE
	PUBLISHED_YEAR > 1950;

-- 3) List all customers from the Canada:
SELECT
	*
FROM
	CUSTOMERS
WHERE
	COUNTRY = 'Canada';

-- 4) Show orders placed in November 2023:
SELECT
	*
FROM
	ORDERS
WHERE
	ORDER_DATE BETWEEN '2023-11-01' AND '2023-11-30';

-- 5) Retrieve the total stock of books available:
SELECT
	SUM(STOCK) AS TOTAL_STOCK
FROM
	BOOKS;

-- 6) Find the details of the most expensive book:
SELECT
	*
FROM
	BOOKS
ORDER BY
	PRICE DESC
LIMIT
	1;

-- 7) Show all customers who ordered more than 1 quantity of a book:
SELECT
	*
FROM
	ORDERS
WHERE
	QUANTITY > 1;

-- 8) Retrieve all orders where the total amount exceeds $20:
SELECT
	*
FROM
	ORDERS
WHERE
	TOTAL_AMOUNT > 20;

-- 9) List all genres available in the Books table:
SELECT DISTINCT
	GENRE
FROM
	BOOKS;

-- 10) Find the book with the lowest stock:
SELECT
	*
FROM
	BOOKS
ORDER BY
	STOCK ASC
LIMIT
	1;

-- 11) Calculate the total revenue generated from all orders:
SELECT
	SUM(TOTAL_AMOUNT) AS TOTAL_REVENUE
FROM
	ORDERS;

SELECT
	*
FROM
	BOOKS;

SELECT
	*
FROM
	CUSTOMERS;

SELECT
	*
FROM
	ORDERS;

-- 12) Retrieve the total number of books sold for each genre:
SELECT
	B.GENRE,
	SUM(O.QUANTITY) AS TOTAL_BOOKS_SOLD
FROM
	ORDERS O
	JOIN BOOKS B ON O.BOOK_ID = B.BOOK_ID
GROUP BY
	B.GENRE;

-- 13) Find the average price of books in the "Fantasy" genre:
SELECT
	AVG(PRICE) AS AVERAGE_PRICE
FROM
	BOOKS
WHERE
	GENRE = 'Fantasy';

-- 14) List customers who have placed at least 2 orders:
SELECT
	CUSTOMER_ID,
	COUNT(ORDER_ID) AS ORDER_COUNT
FROM
	ORDERS
GROUP BY
	CUSTOMER_ID
HAVING
	COUNT(ORDER_ID) >= 2;

-- 15) Find the most frequently ordered book:
SELECT
	BOOK_ID,
	COUNT(ORDER_ID) AS ORDER_COUNT
FROM
	ORDERS
GROUP BY
	BOOK_ID
ORDER BY
	ORDER_COUNT DESC
LIMIT
	1;

-- 16) Show the top 3 most expensive books of 'Fantasy' Genre :
SELECT
	*
FROM
	BOOKS
WHERE
	GENRE = 'Fantasy'
ORDER BY
	PRICE DESC
LIMIT
	3;

-- 17) Retrieve the total quantity of books sold by each author:
SELECT
	B.AUTHOR,
	SUM(O.QUANTITY) AS TOTAL_BOOKS_SOLD
FROM
	ORDERS O
	JOIN BOOKS B ON O.BOOK_ID = B.BOOK_ID
GROUP BY
	B.AUTHOR;

SELECT
	*
FROM
	BOOKS;

SELECT
	*
FROM
	CUSTOMERS;

SELECT
	*
FROM
	ORDERS;

-- 18) List the cities where customers who spent over $30 are located:
SELECT DISTINCT
	C.CITY
FROM
	CUSTOMERS AS C
	JOIN ORDERS AS O ON O.CUSTOMER_ID = C.CUSTOMER_ID
WHERE
	TOTAL_AMOUNT >= 30;

-- 19) Find the customer who spent the most on orders:
SELECT
	C.NAME,
	O.CUSTOMER_ID,
	COUNT(O.CUSTOMER_ID),
	SUM(O.TOTAL_AMOUNT)
FROM
	ORDERS AS O
	JOIN CUSTOMERS AS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY
	O.CUSTOMER_ID,
	C.NAME;

--20) Calculate the stock remaining after fulfilling all orders:
SELECT
	B.TITLE,
	B.STOCk - COALESCE(SUM(O.QUANTITY), 0)
FROM
	BOOKS AS B
	LEFT JOIN ORDERS AS O ON O.BOOK_ID = B.BOOK_ID
GROUP BY
	B.TITLE, b.stock;

--21) Find all customers who have spent more than the average total spending of all customers.
WITH
	AVG_TABLE AS (
		SELECT
			CUSTOMER_ID,
			AVG(TOTAL_AMOUNT) AS AVERAGE
		FROM
			ORDERS
		WHERE
			TOTAL_AMOUNT > (
				SELECT
					AVG(TOTAL_AMOUNT)
				FROM
					ORDERS
			)
		GROUP BY
			CUSTOMER_ID
	)
SELECT
	NAME
FROM
	CUSTOMERS
WHERE
	CUSTOMER_ID IN (
		SELECT
			CUSTOMER_ID
		FROM
			AVG_TABLE
	);

--22) Calculate how many copies each book sold
WITH
	COP AS (
		SELECT
			BOOK_ID,
			SUM(QUANTITY) AS TOTAL
		FROM
			ORDERS
		GROUP BY
			BOOK_ID
	)
SELECT
	B.TITLE,
	C.TOTAL
FROM
	BOOKS AS B
	LEFT JOIN COP AS C ON B.BOOK_ID = C.BOOK_ID;

--23)find top 3 best-selling books
WITH
	BOOKS_COUNT AS (
		SELECT
			BOOK_ID,
			SUM(QUANTITY) AS TOTAL_QUANTITY
		FROM
			ORDERS
		GROUP BY
			BOOK_ID
		ORDER BY
			SUM(QUANTITY) DESC
		LIMIT
			(3)
	)
SELECT
	B.TITLE,
	C.TOTAL_QUANTITY
FROM
	BOOKS AS B
	JOIN BOOKS_COUNT AS C ON B.BOOK_ID = C.BOOK_ID;

--24)Find the top-selling book in each genre, using a CTE to calculate
--total sales and a window function to rank books within each genre.
WITH
	TOTAL_AMT AS (
		SELECT
			BOOK_ID,
			SUM(TOTAL_AMOUNT) AS TOTAL
		FROM
			ORDERS
		GROUP BY
			BOOK_ID
	),
	RANK_TAB AS (
		SELECT
			B.GENRE,
			B.TITLE,
			T.TOTAL,
			RANK() OVER (
				PARTITION BY
					GENRE
				ORDER BY
					TOTAL DESC
			) AS rnk
		FROM
			TOTAL_AMT AS T
			JOIN BOOKS AS B ON B.BOOK_ID = T.BOOK_ID
	)
SELECT
	GENRE,
	TITLE,
	TOTAL
FROM
	RANK_TAB
WHERE
	rnk = 1;

--25)Top 2 Customers Per City 

WITH
	TOTAL_AMT AS (
		SELECT
			BOOK_ID,
			SUM(TOTAL_AMOUNT) AS TOTAL
		FROM
			ORDERS
		GROUP BY
			BOOK_ID
	),
	RANK_TAB AS (
		SELECT
			B.GENRE,
			B.TITLE,
			T.TOTAL,
			RANK() OVER (
				PARTITION BY
					GENRE
				ORDER BY
					TOTAL DESC
			) AS rnk
		FROM
			TOTAL_AMT AS T
			JOIN BOOKS AS B ON B.BOOK_ID = T.BOOK_ID
	)
SELECT
	GENRE,
	TITLE,
	TOTAL,
	rnk
FROM
	RANK_TAB
WHERE
	rnk in (1,2);

--26) Find the top 2 highest-spending customers in each city.
WITH
	TOTAL AS (
		SELECT
			CUSTOMER_ID,
			SUM(TOTAL_AMOUNT) AS TAMT
		FROM
			ORDERS
		GROUP BY
			CUSTOMER_ID
	),
	CUSTOMER_RANK AS (
		SELECT
			C.CITY,
			C.NAME,
			T.TAMT,
			RANK() OVER (
				PARTITION BY
					C.CITY
				ORDER BY
					TAMT DESC
			) AS RNK
		FROM
			CUSTOMERS AS C
			JOIN TOTAL AS T ON C.CUSTOMER_ID = T.CUSTOMER_ID
	)
SELECT
	CITY,
	NAME,
	TAMT,
	RNK
FROM
	CUSTOMER_RANK
WHERE
	RNK IN (1, 2);

SELECT
	*
FROM
	BOOKS;

SELECT
	*
FROM
	CUSTOMERS;

SELECT
	*
FROM
	ORDERS;
	
--27)Calculate the total revenue for each month AND a running cumulative revenue across months.
WITH
	MONTHLY_REVENUE AS (
		SELECT
			DATE_TRUNC('month', ORDER_DATE) AS MONTHS,
			SUM(TOTAL_AMOUNT) AS REVENUE
		FROM
			ORDERS
		GROUP BY
			MONTHS
	)
SELECT
	MONTHS,
	REVENUE,
	SUM(REVENUE) OVER (
		ORDER BY
			MONTHS
	)
FROM
	MONTHLY_REVENUE
ORDER BY
	MONTHS;
--28)Identify the books that together contribute to the first 80% of total revenue.

WITH
	BOOK_REVENUE AS (
		SELECT
			B.TITLE,
			O.BOOK_ID,
			SUM(O.TOTAL_AMOUNT) AS AMT
		FROM
			ORDERS AS O
			LEFT JOIN BOOKS AS B ON B.BOOK_ID = O.BOOK_ID
		GROUP BY
			B.TITLE,
			O.BOOK_ID
	),
	COMULATIVE AS (
		SELECT
			TITLE,
			BOOK_ID,
			AMT,
			SUM(AMT) OVER (
				ORDER BY
					AMT DESC
			) AS CAMT,
			SUM(AMT) OVER () AS TOTAL
		FROM
			BOOK_REVENUE
	)
SELECT
	TITLE,
	AMT,
	CAMT
FROM
	COMULATIVE
WHERE
	CAMT / TOTAL <= 0.80
ORDER BY
	amt DESC;


--29) For each genre, find the book with the second-highest total revenue.

	WITH
	TOTAL_AMT AS (
		SELECT
			BOOK_ID,
			SUM(TOTAL_AMOUNT) AS TOTAL
		FROM
			ORDERS
		GROUP BY
			BOOK_ID
	),
	RANK_TAB AS (
		SELECT
			B.GENRE,
			B.TITLE,
			T.TOTAL,
			RANK() OVER (
				PARTITION BY
					GENRE
				ORDER BY
					TOTAL DESC
			) AS rnk
		FROM
			TOTAL_AMT AS T
			JOIN BOOKS AS B ON B.BOOK_ID = T.BOOK_ID
	)
SELECT
	GENRE,
	TITLE,
	TOTAL
FROM
	RANK_TAB
WHERE
	rnk = 2;

--Q30)Generate a list of high-value customers (those who spent more than the monthly average),
--and store results in a TEMP TABLE for fast processing. Then create a VIEW that always shows these
--high-value customers with their city and total lifetime spending.”
drop view if exists heigh_spending_customer ;
DROP TABLE IF EXISTS MORE_THEN_AVG_CUS;

CREATE TEMPORARY TABLE MORE_THEN_AVG_CUS AS
SELECT
	C.CUSTOMER_ID,
	C.NAME,
	C.CITY,
	DATE_TRUNC('month', O.ORDER_DATE) AS MONTH,
	SUM(O.TOTAL_AMOUNT) AS MONTHLY_SPEND
FROM
	ORDERS AS O
	JOIN CUSTOMERS AS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY
	C.CITY,
	C.CUSTOMER_ID,
	MONTH,
	C.NAME;

SELECT
	*
FROM
	MORE_THEN_AVG_CUS;

	DROP TABLE IF EXISTS HEIGH_VALUE_CUS;

CREATE TEMPORARY TABLE HEIGH_VALUE_CUS AS

with average as (SELECT
	NAME,
	CITY,
	MONTH,
	MONTHLY_SPEND,
	AVG(MONTHLY_SPEND) OVER (
		PARTITION BY
			MONTH
	) as monthly_average
FROM
	MORE_THEN_AVG_CUS) select NAME,
	CITY,
	MONTH,
	MONTHLY_SPEND,
	 monthly_average
FROM average
where MONTHLY_SPEND > monthly_average;

	
	SELECT
	*
FROM
	HEIGH_VALUE_CUS;


create view heigh_spending_customer as select NAME,
	CITY,
	MONTH,
	MONTHLY_SPEND,
	 monthly_average
FROM HEIGH_VALUE_CUS 
order by month ,monthly_spend ;

select * from heigh_spending_customer;
