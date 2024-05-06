-- Use DB
USE movie_ticket_sales;

-- Sales Trends Over Time
SELECT DATE(sale_time) AS sale_date, SUM(sale_amount) AS total_sales
FROM Sales
GROUP BY sale_date
ORDER BY sale_date;