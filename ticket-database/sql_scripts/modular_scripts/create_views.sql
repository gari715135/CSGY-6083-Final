-- Create Views
-- View for Available Seats per Showtime
CREATE VIEW AvailableSeats AS
SELECT st.showtime_id, st.screen_id, m.title, 
       (scr.capacity - IFNULL(bt.booked_tickets, 0)) AS available_seats
FROM Showtimes st
JOIN Movies m ON st.movie_id = m.movie_id
JOIN Screens scr ON st.screen_id = scr.screen_id
LEFT JOIN (SELECT showtime_id, COUNT(*) as booked_tickets 
           FROM Tickets 
           JOIN Seats ON Tickets.seat_id = Seats.seat_id 
           WHERE Seats.seat_status = 'booked'
           GROUP BY showtime_id) bt ON st.showtime_id = bt.showtime_id;

-- View for Sales Summary by Movie
CREATE VIEW SalesSummaryByMovie AS
SELECT m.title, COUNT(t.ticket_id) AS tickets_sold, SUM(sale.sale_amount) AS total_sales
FROM Tickets t
JOIN Showtimes st ON t.showtime_id = st.showtime_id
JOIN Movies m ON st.movie_id = m.movie_id
JOIN Sales sale ON t.ticket_id = sale.ticket_id
GROUP BY m.title;

-- View for Current Movie Schedule
CREATE VIEW CurrentMovieSchedule AS
SELECT m.title, s.showtime, st.screen_name, s.showtime_id
FROM Showtimes s
JOIN Movies m ON s.movie_id = m.movie_id
JOIN Screens scr ON s.screen_id = scr.screen_id
JOIN ScreenTypes st ON scr.screen_type_id = st.screen_type_id
WHERE s.showtime > NOW()
ORDER BY s.showtime;