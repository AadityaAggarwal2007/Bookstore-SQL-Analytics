📚 Bookstore Sales & Customer Analytics (SQL Project)
📌 Project Overview

This project models a bookstore sales system and performs comprehensive SQL-based analysis on books, customers, and orders.
The objective is to answer business-oriented questions using structured SQL queries, progressing from basic data retrieval to advanced analytical scenarios.

🗂 Database Schema

The database consists of three core tables:

BOOKS – Book details including genre, pricing, and stock

CUSTOMERS – Customer information and location details

ORDERS – Transactional data linking customers and books

Relationships

One customer can place multiple orders

Each book can be ordered multiple times

🛠 Tools & Technologies

PostgreSQL

SQL Concepts Used

JOIN, GROUP BY, HAVING

Subqueries

CTEs (WITH clause)

Window Functions (RANK, SUM() OVER)

Temporary Tables

Views

Date functions (DATE_TRUNC)

🔑 Key Analytics & Solutions
1️⃣ Monthly Revenue & Running Growth Trend

What: Calculated total revenue per month and cumulative revenue over time.
Why: Helps track growth momentum and identify revenue trends across periods.

How (SQL):

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(total_amount) AS revenue
    FROM orders
    GROUP BY month
)
SELECT
    month,
    revenue,
    SUM(revenue) OVER (ORDER BY month) AS cumulative_revenue
FROM monthly_revenue;


📊 Table snapshot added to visually show growth progression.

2️⃣ Top-Selling Book in Each Genre

What: Identified the highest revenue-generating book per genre.
Why: Helps understand genre leaders and optimize inventory or promotions.

How (SQL):

WITH total_sales AS (
    SELECT
        book_id,
        SUM(total_amount) AS total_revenue
    FROM orders
    GROUP BY book_id
),
ranked_books AS (
    SELECT
        b.genre,
        b.title,
        t.total_revenue,
        RANK() OVER (PARTITION BY b.genre ORDER BY t.total_revenue DESC) AS rnk
    FROM total_sales t
    JOIN books b ON b.book_id = t.book_id
)
SELECT genre, title, total_revenue
FROM ranked_books
WHERE rnk = 1;


📊 Table highlights genre-wise leaders.

3️⃣ High-Value Customers (Above Monthly Average Spend)

What: Identified customers who spent more than the average monthly spending.
Why: Useful for customer segmentation and targeted marketing strategies.

How (SQL):

WITH monthly_spend AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', order_date) AS month,
        SUM(total_amount) AS spend
    FROM orders
    GROUP BY customer_id, month
),
ranked_customers AS (
    SELECT *,
           AVG(spend) OVER (PARTITION BY month) AS avg_monthly_spend
    FROM monthly_spend
)
SELECT *
FROM ranked_customers
WHERE spend > avg_monthly_spend;


📊 Table view used to showcase qualifying customers.

4️⃣ Pareto Analysis – Top 80% Revenue Contributors

What: Identified books contributing to the first 80% of total revenue.
Why: Demonstrates the 80/20 principle and helps prioritize high-impact products.

How (SQL):

WITH book_revenue AS (
    SELECT
        book_id,
        SUM(total_amount) AS revenue
    FROM orders
    GROUP BY book_id
),
cumulative_revenue AS (
    SELECT
        book_id,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS running_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM book_revenue
)
SELECT *
FROM cumulative_revenue
WHERE running_revenue / total_revenue <= 0.80;


📊 Table makes revenue concentration visually obvious.

5️⃣ Top 2 Customers per City

What: Ranked customers by total spending within each city.
Why: Helps identify premium customers region-wise.

How (SQL):

WITH total_spend AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
city_ranking AS (
    SELECT
        c.city,
        c.name,
        t.total_spent,
        RANK() OVER (PARTITION BY c.city ORDER BY t.total_spent DESC) AS rnk
    FROM customers c
    JOIN total_spend t ON c.customer_id = t.customer_id
)
SELECT *
FROM city_ranking
WHERE rnk IN (1, 2);


📊 Table snapshot improves readability and impact.

📈 Outcome

The project demonstrates practical SQL usage for:

Sales analysis

Customer segmentation

Revenue tracking

Inventory evaluation

✅ Status

Completed
