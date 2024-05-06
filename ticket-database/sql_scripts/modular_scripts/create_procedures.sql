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