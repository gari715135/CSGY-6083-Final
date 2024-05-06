SELECT Movies.title, COUNT(Tickets.ticket_id) AS tickets_sold
FROM Movies
JOIN Showtimes ON Movies.movie_id = Showtimes.movie_id
JOIN Tickets ON Showtimes.showtime_id = Tickets.showtime_id
GROUP BY Movies.movie_id
ORDER BY tickets_sold DESC;