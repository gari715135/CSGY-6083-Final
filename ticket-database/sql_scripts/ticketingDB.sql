/********************************************************
This script is a compilation of all scripts in the "modular" directory.
This makes deploying DB easier but is not best practice.
*********************************************************/
SET GLOBAL log_bin_trust_function_creators = 1;

-- Create DB
DROP DATABASE IF EXISTS movie_ticket_sales;
CREATE DATABASE movie_ticket_sales;
USE movie_ticket_sales;

-- Drop tables if they exist
DROP TABLE IF EXISTS Users, Tickets, Showtimes, Seats, Screens, ScreenTypes, Movies, Customers, Sales CASCADE;

-- Users Table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE,
    password VARCHAR(255),
    role ENUM('customer', 'admin') DEFAULT 'customer'
);

-- Customers Table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,  -- Reference to Users table
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Movies Table
CREATE TABLE Movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    director VARCHAR(255),
    runtime INT,
    rating VARCHAR(50)
);

-- ScreenTypes Table
CREATE TABLE ScreenTypes (
    screen_type_id INT AUTO_INCREMENT PRIMARY KEY,
    screen_name VARCHAR(255) NOT NULL
);

-- Screens Table
CREATE TABLE Screens (
    screen_id INT AUTO_INCREMENT PRIMARY KEY,
    screen_type_id INT NOT NULL,
    capacity INT,
    FOREIGN KEY (screen_type_id) REFERENCES ScreenTypes(screen_type_id)
);

-- Seats Table
CREATE TABLE Seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    screen_id INT,
    seat_number INT,
    seat_status VARCHAR(50) DEFAULT 'available',
    FOREIGN KEY (screen_id) REFERENCES Screens(screen_id)
);

-- Showtimes Table
CREATE TABLE Showtimes (
    showtime_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT,
    screen_id INT,
    showtime DATETIME,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (screen_id) REFERENCES Screens(screen_id)
);

-- Tickets Table
CREATE TABLE Tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    showtime_id INT,
    seat_id INT,
    customer_id INT,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (showtime_id) REFERENCES Showtimes(showtime_id),
    FOREIGN KEY (seat_id) REFERENCES Seats(seat_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Sales Table
CREATE TABLE Sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT UNIQUE,
    sale_amount DECIMAL(10,2),
    sale_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);


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

-- Define Functions
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


-- Create Procedures
-- Generate Seats
DELIMITER $$

CREATE PROCEDURE GenerateSeatsForScreen(IN screenId INT, IN screenCapacity INT) 
BEGIN
    DECLARE seatNumber INT DEFAULT 0;
    -- Loop to insert seats up to the screenCapacity
    WHILE seatNumber < screenCapacity DO
        SET seatNumber = seatNumber + 1;
        -- Insert the seat into the Seats table
        INSERT INTO Seats (screen_id, seat_number, seat_status)
        VALUES (screenId, seatNumber, 'available');
        END WHILE;
END$$ 

DELIMITER;

-- Procedure to Buy a Ticket
DELIMITER $$

CREATE PROCEDURE BookTicket(IN customerID INT, IN showtimeID INT, IN seatID INT)
BEGIN
    DECLARE seatAvailable VARCHAR(50);
    
    -- Check if the seat is available
    SELECT seat_status INTO seatAvailable FROM Seats WHERE seat_id = seatID;
    IF seatAvailable = 'available' THEN
        -- Insert ticket information
        INSERT INTO Tickets (showtime_id, seat_id, customer_id) VALUES (showtimeID, seatID, customerID);
        -- Update seat status to 'booked'
        UPDATE Seats SET seat_status = 'booked' WHERE seat_id = seatID;
        SELECT 'Ticket booked Successfully' AS Result;
    ELSE
        SELECT 'Seat Not Available' AS Result;
    END IF;
END$$
DELIMITER ;

-- Procedure to Check Seat Availability
DELIMITER $$ 

CREATE PROCEDURE CheckSeatAvailability(IN showtimeID INT) BEGIN
SELECT s.seat_id,
    s.seat_number,
    s.seat_status
FROM Seats s
    JOIN Showtimes st ON s.screen_id = st.screen_id
WHERE st.showtime_id = showtimeID
    AND s.seat_id NOT IN (
        SELECT t.seat_id
        FROM Tickets t
        WHERE t.showtime_id = showtimeID
    )
    AND s.seat_status = 'available';
END$$
DELIMITER ;

-- Procedure to Cancel a Ticket
DELIMITER $$

CREATE PROCEDURE CancelTicket(IN ticketID INT)
BEGIN
    DECLARE seatID INT;
    
    -- Find the seat ID associated with the ticket
    SELECT seat_id INTO seatID FROM Tickets WHERE ticket_id = ticketID;
    
    -- Update seat status back to 'available'
    UPDATE Seats SET seat_status = 'available' WHERE seat_id = seatID;
    
    DELETE FROM Sales WHERE ticket_id = ticketID;

    DELETE FROM Tickets WHERE ticket_id = ticketID;

    SELECT 'Ticket Canceled Successfully' AS Result;
END$$

DELIMITER ;


-- Create Triggers
-- Prevent Ticket Sales for Sold-Out Shows
DELIMITER $$

CREATE TRIGGER PreventSoldOutSales BEFORE INSERT ON Tickets FOR EACH ROW
BEGIN
    DECLARE showCapacity INT;
    DECLARE ticketsSold INT;
    
    -- Get the total capacity of the screen
    SELECT capacity INTO showCapacity FROM Screens scr JOIN Showtimes st ON scr.screen_id = st.screen_id WHERE st.showtime_id = NEW.showtime_id;
    
    -- Get the number of tickets already sold
    SELECT COUNT(*) INTO ticketsSold FROM Tickets WHERE showtime_id = NEW.showtime_id;
    
    -- Prevent insert if the show is sold out
    IF ticketsSold >= showCapacity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot sell ticket: Show is sold out.';
    END IF;
END$$
DELIMITER ;

-- -- Restrict Ticket Bookings After Showtime
-- DELIMITER $$

-- CREATE TRIGGER RestrictLateBookings BEFORE INSERT ON Tickets FOR EACH ROW
-- BEGIN
--     DECLARE showTime DATETIME;
    
--     -- Get the showtime
--     SELECT showtime INTO showTime FROM Showtimes WHERE showtime_id = NEW.showtime_id;
    
--     -- Prevent ticket booking if it's beyond 15 minutes after the showtime
--     IF NOW() > DATE_ADD(showTime, INTERVAL 15 MINUTE) THEN
--         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot booking ticket: Booking is beyond allowed time.';
--     END IF;
-- END$$

-- DELIMITER ;

-- Update Sales After Ticket Booking
DELIMITER $$

CREATE TRIGGER UpdateSalesAfterbooking AFTER INSERT ON Tickets FOR EACH ROW
BEGIN
    -- Assuming ticket price is a fixed value, for simplicity
    INSERT INTO Sales (ticket_id, sale_amount) VALUES (NEW.ticket_id, 10.00); -- Example fixed price
END$$

DELIMITER ;

-- Update Sales After Ticket Cancellation
DELIMITER $$

CREATE TRIGGER UpdateSalesAfterCancellation AFTER DELETE ON Tickets FOR EACH ROW
BEGIN
    -- Delete the corresponding sale record
    DELETE FROM Sales WHERE ticket_id = OLD.ticket_id;
END$$

DELIMITER ;
