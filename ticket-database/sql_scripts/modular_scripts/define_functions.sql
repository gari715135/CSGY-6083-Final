- Define Functions
-- Calculate Total Sales for a Movie
DELIMITER $$
CREATE FUNCTION TotalSalesForMovie(movieID INT) RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE totalSales DECIMAL(10,2) DEFAULT 0;
    SELECT SUM(s.sale_amount) INTO totalSales
    FROM Sales s
    JOIN Tickets t ON s.ticket_id = t.ticket_id
    JOIN Showtimes st ON t.showtime_id = st.showtime_id
    WHERE st.movie_id = movieID;
    RETURN IFNULL(totalSales, 0);
END$$
DELIMITER ;

-- Number of Tickets Sold for a Showtime
DELIMITER $$
CREATE FUNCTION TicketsSoldForShowtime(showtimeID INT) RETURNS INT
BEGIN
    DECLARE ticketsSold INT;
    SELECT COUNT(*) INTO ticketsSold FROM Tickets WHERE showtime_id = showtimeID;
    RETURN ticketsSold;
END$$
DELIMITER ;

-- Determine if a Showtime is Sold Out
DELIMITER $$
CREATE FUNCTION IsShowtimeSoldOut(showtimeID INT) RETURNS VARCHAR(5)
BEGIN
    DECLARE capacity INT;
    DECLARE ticketsSold INT;
    
    -- Get the screen capacity for the showtime
    SELECT scr.capacity INTO capacity
    FROM Screens scr
    JOIN Showtimes st ON scr.screen_id = st.screen_id
    WHERE st.showtime_id = showtimeID;
    
    -- Get the number of tickets sold
    SET ticketsSold = TicketsSoldForShowtime(showtimeID);

    -- Check if the showtime is sold out
    IF capacity <= ticketsSold THEN
        RETURN 'Yes';
    ELSE
        RETURN 'No';
    END IF;
END$$
DELIMITER ;