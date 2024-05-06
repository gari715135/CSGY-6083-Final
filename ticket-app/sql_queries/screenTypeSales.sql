-- Use DB
USE movie_ticket_sales;

-- Sales by Screen Type
SELECT ScreenTypes.screen_name, SUM(Sales.sale_amount) AS total_sales
FROM ScreenTypes
JOIN Screens ON ScreenTypes.screen_type_id = Screens.screen_type_id
JOIN Showtimes ON Screens.screen_id = Showtimes.screen_id
JOIN Tickets ON Showtimes.showtime_id = Tickets.showtime_id
JOIN Sales ON Tickets.ticket_id = Sales.ticket_id
GROUP BY ScreenTypes.screen_type_id
ORDER BY total_sales DESC;