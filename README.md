# 📚 Bookstore Sales & Customer Analytics (SQL Project)

A structured SQL analytics project that models a bookstore sales system and answers real business questions using clean, production-style queries.

---

## 📌 Project Overview

This project simulates a bookstore’s sales database and performs **end-to-end SQL analysis** on books, customers, and orders.

The goal is to move from **basic querying** to **advanced analytical insights**, focusing on questions a business would actually care about — revenue growth, top products, and high-value customers.

---

## 🗂 Database Schema

The database contains **three core tables**:

* **BOOKS** – Book details including genre, pricing, and stock
* **CUSTOMERS** – Customer information and location details
* **ORDERS** – Transactional data linking customers and books

### Relationships

* One customer can place multiple orders
* Each book can be ordered multiple times

---

## 🛠 Tools & Technologies

* **PostgreSQL**

### SQL Concepts Used

* `JOIN`, `GROUP BY`, `HAVING`
* Subqueries
* CTEs (`WITH` clause)
* Window Functions (`RANK`, `SUM() OVER`)
* Temporary Tables
* Views
* Date functions (`DATE_TRUNC`)

---

## 🔑 Key Analytics & Solutions

### 1️⃣ Monthly Revenue & Running Growth Trend

**What:**
Calculated total revenue per month and cumulative revenue over time.

**Why:**
Helps track growth momentum and identify revenue trends across periods.

**How (SQL):**

```sql
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
```

📊 Table snapshot added to visually show revenue growth progression.

---

### 2️⃣ Top-Selling Book in Each Genre

**What:**
Identified the highest revenue-generating book in every genre.

**Why:**
Useful for inventory planning, promotions, and genre-level performance tracking.

**How (SQL):**

```sql
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
```

📊 Output table highlights genre-wise bestsellers.

---

### 3️⃣ High-Value Customers (Above Monthly Average Spend)

**What:**
Identified customers whose monthly spend exceeded the average spend for that month.

**Why:**
Enables customer segmentation and targeted marketing strategies.

**How (SQL):**

```sql
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
```
<img width="1586" height="1192" alt="image" src="https://github.com/user-attachments/assets/88af99ac-71b9-4282-bf28-842d8fbea0fc" />

📊 Table view used to showcase qualifying customers.

---

### 4️⃣ Pareto Analysis – Top 80% Revenue Contributors

**What:**
Identified books contributing to the first **80% of total revenue**.

**Why:**
Demonstrates the **80/20 principle** and helps prioritize high-impact products.

**How (SQL):**

```sql
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
```

📊 Output clearly shows revenue concentration.

---

### 5️⃣ Top 2 Customers per City

**What:**
Ranked customers based on total spending within each city.

**Why:**
Helps identify premium customers at a regional level.

**How (SQL):**

```sql
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
```

📊 Table snapshot improves clarity and impact.

---

## 📈 Outcome

This project demonstrates **practical, business-focused SQL usage** for:

* Sales analysis
* Customer segmentation
* Revenue tracking
* Inventory evaluation

---

## ✅ Status

**Completed**
