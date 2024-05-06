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

-- Restrict Ticket Bookings After Showtime
DELIMITER $$

CREATE TRIGGER RestrictLateBookings BEFORE INSERT ON Tickets FOR EACH ROW
BEGIN
    DECLARE showTime DATETIME;
    
    -- Get the showtime
    SELECT showtime INTO showTime FROM Showtimes WHERE showtime_id = NEW.showtime_id;
    
    -- Prevent ticket booking if it's beyond 15 minutes after the showtime
    IF NOW() > DATE_ADD(showTime, INTERVAL 15 MINUTE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot booking ticket: Booking is beyond allowed time.';
    END IF;
END$$

DELIMITER ;

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