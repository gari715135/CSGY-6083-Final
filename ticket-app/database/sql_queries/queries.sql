-- Use DB
USE movie_ticket_sales;

-- Screen Utilization
SELECT 
    Screens.screen_id,
    ScreenTypes.screen_name,
    (SELECT COUNT(*) FROM Seats WHERE Seats.screen_id = Screens.screen_id) AS total_seats,
    (SELECT COUNT(*) FROM Tickets 
      JOIN Showtimes ON Tickets.showtime_id = Showtimes.showtime_id
      WHERE Showtimes.screen_id = Screens.screen_id) AS occupied_seats,
    ROUND((occupied_seats / total_seats) * 100, 2) AS occupancy_rate,
    (SELECT SUM(sale_amount) FROM Sales 
      JOIN Tickets ON Sales.ticket_id = Tickets.ticket_id
      JOIN Showtimes ON Tickets.showtime_id = Showtimes.showtime_id
      WHERE Showtimes.screen_id = Screens.screen_id) AS revenue_generated
FROM Screens
JOIN ScreenTypes ON Screens.screen_type_id = ScreenTypes.screen_type_id;

-- salesSummaryByMovie
SELECT * FROM salessummarybymovie;