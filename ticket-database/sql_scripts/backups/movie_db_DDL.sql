-- MySQL Workbench Forward Engineering
SET GLOBAL log_bin_trust_function_creators = 1;

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema movie_ticket_sales
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `movie_ticket_sales` ;

-- -----------------------------------------------------
-- Schema movie_ticket_sales
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `movie_ticket_sales` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `movie_ticket_sales` ;

-- -----------------------------------------------------
-- Table `Users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Users` ;

CREATE TABLE IF NOT EXISTS `Users` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(255) NULL DEFAULT NULL,
  `password` VARCHAR(255) NULL DEFAULT NULL,
  `role` ENUM('customer', 'admin') NULL DEFAULT 'customer',
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `username` (`username` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Customers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Customers` ;

CREATE TABLE IF NOT EXISTS `Customers` (
  `customer_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NULL DEFAULT NULL,
  `name` VARCHAR(255) NULL DEFAULT NULL,
  `email` VARCHAR(255) NULL DEFAULT NULL,
  `phone_number` VARCHAR(50) NULL DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  UNIQUE INDEX `user_id` (`user_id` ASC) VISIBLE,
  UNIQUE INDEX `email` (`email` ASC) VISIBLE,
  CONSTRAINT `customers_ibfk_1`
    FOREIGN KEY (`user_id`)
    REFERENCES `Users` (`user_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Movies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Movies` ;

CREATE TABLE IF NOT EXISTS `Movies` (
  `movie_id` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `director` VARCHAR(255) NULL DEFAULT NULL,
  `runtime` INT NULL DEFAULT NULL,
  `rating` VARCHAR(50) NULL DEFAULT NULL,
  PRIMARY KEY (`movie_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `ScreenTypes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ScreenTypes` ;

CREATE TABLE IF NOT EXISTS `ScreenTypes` (
  `screen_type_id` INT NOT NULL AUTO_INCREMENT,
  `screen_name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`screen_type_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Screens`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Screens` ;

CREATE TABLE IF NOT EXISTS `Screens` (
  `screen_id` INT NOT NULL AUTO_INCREMENT,
  `screen_type_id` INT NOT NULL,
  `capacity` INT NULL DEFAULT NULL,
  PRIMARY KEY (`screen_id`),
  INDEX `screen_type_id` (`screen_type_id` ASC) VISIBLE,
  CONSTRAINT `screens_ibfk_1`
    FOREIGN KEY (`screen_type_id`)
    REFERENCES `ScreenTypes` (`screen_type_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Showtimes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Showtimes` ;

CREATE TABLE IF NOT EXISTS `Showtimes` (
  `showtime_id` INT NOT NULL AUTO_INCREMENT,
  `movie_id` INT NULL DEFAULT NULL,
  `screen_id` INT NULL DEFAULT NULL,
  `showtime` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`showtime_id`),
  INDEX `movie_id` (`movie_id` ASC) VISIBLE,
  INDEX `screen_id` (`screen_id` ASC) VISIBLE,
  CONSTRAINT `showtimes_ibfk_1`
    FOREIGN KEY (`movie_id`)
    REFERENCES `Movies` (`movie_id`),
  CONSTRAINT `showtimes_ibfk_2`
    FOREIGN KEY (`screen_id`)
    REFERENCES `Screens` (`screen_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 55
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Seats`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Seats` ;

CREATE TABLE IF NOT EXISTS `Seats` (
  `seat_id` INT NOT NULL AUTO_INCREMENT,
  `screen_id` INT NULL DEFAULT NULL,
  `seat_number` INT NULL DEFAULT NULL,
  `seat_status` VARCHAR(50) NULL DEFAULT 'available',
  PRIMARY KEY (`seat_id`),
  INDEX `screen_id` (`screen_id` ASC) VISIBLE,
  CONSTRAINT `seats_ibfk_1`
    FOREIGN KEY (`screen_id`)
    REFERENCES `Screens` (`screen_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 13
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Tickets`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Tickets` ;

CREATE TABLE IF NOT EXISTS `Tickets` (
  `ticket_id` INT NOT NULL AUTO_INCREMENT,
  `showtime_id` INT NULL DEFAULT NULL,
  `seat_id` INT NULL DEFAULT NULL,
  `customer_id` INT NULL DEFAULT NULL,
  `booking_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ticket_id`),
  INDEX `showtime_id` (`showtime_id` ASC) VISIBLE,
  INDEX `seat_id` (`seat_id` ASC) VISIBLE,
  INDEX `customer_id` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `tickets_ibfk_1`
    FOREIGN KEY (`showtime_id`)
    REFERENCES `Showtimes` (`showtime_id`),
  CONSTRAINT `tickets_ibfk_2`
    FOREIGN KEY (`seat_id`)
    REFERENCES `Seats` (`seat_id`),
  CONSTRAINT `tickets_ibfk_3`
    FOREIGN KEY (`customer_id`)
    REFERENCES `Customers` (`customer_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Sales`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Sales` ;

CREATE TABLE IF NOT EXISTS `Sales` (
  `sale_id` INT NOT NULL AUTO_INCREMENT,
  `ticket_id` INT NULL DEFAULT NULL,
  `sale_amount` DECIMAL(10,2) NULL DEFAULT NULL,
  `sale_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sale_id`),
  UNIQUE INDEX `ticket_id` (`ticket_id` ASC) VISIBLE,
  CONSTRAINT `sales_ibfk_1`
    FOREIGN KEY (`ticket_id`)
    REFERENCES `Tickets` (`ticket_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `movie_ticket_sales` ;

-- -----------------------------------------------------
-- procedure BookTicket
-- -----------------------------------------------------

USE `movie_ticket_sales`;
DROP procedure IF EXISTS `BookTicket`;

DELIMITER $$
USE `movie_ticket_sales`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `BookTicket`(IN customerID INT, IN showtimeID INT, IN seatID INT)
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

-- -----------------------------------------------------
-- procedure CancelTicket
-- -----------------------------------------------------

USE `movie_ticket_sales`;
DROP procedure IF EXISTS `CancelTicket`;

DELIMITER $$
USE `movie_ticket_sales`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CancelTicket`(IN ticketID INT)
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

-- -----------------------------------------------------
-- procedure CheckSeatAvailability
-- -----------------------------------------------------

USE `movie_ticket_sales`;
DROP procedure IF EXISTS `CheckSeatAvailability`;

DELIMITER $$
USE `movie_ticket_sales`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckSeatAvailability`(IN showtimeID INT)
BEGIN
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

-- -----------------------------------------------------
-- procedure GenerateSeatsForScreen
-- -----------------------------------------------------

USE `movie_ticket_sales`;
DROP procedure IF EXISTS `GenerateSeatsForScreen`;

DELIMITER $$
USE `movie_ticket_sales`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerateSeatsForScreen`(IN screenId INT, IN screenCapacity INT)
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

DELIMITER ;

-- -----------------------------------------------------
-- function IsShowtimeSoldOut
-- -----------------------------------------------------

USE `movie_ticket_sales`;
DROP function IF EXISTS `IsShowtimeSoldOut`;

DELIMITER $$
USE `movie_ticket_sales`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `IsShowtimeSoldOut`(showtimeID INT) RETURNS varchar(5) CHARSET utf8mb4
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

-- -----------------------------------------------------
-- function TicketsSoldForShowtime
-- -----------------------------------------------------

USE `movie_ticket_sales`;
DROP function IF EXISTS `TicketsSoldForShowtime`;

DELIMITER $$
USE `movie_ticket_sales`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `TicketsSoldForShowtime`(showtimeID INT) RETURNS int
BEGIN
    DECLARE ticketsSold INT;
    SELECT COUNT(*) INTO ticketsSold FROM Tickets WHERE showtime_id = showtimeID;
    RETURN ticketsSold;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function TotalSalesForMovie
-- -----------------------------------------------------

USE `movie_ticket_sales`;
DROP function IF EXISTS `TotalSalesForMovie`;

DELIMITER $$
USE `movie_ticket_sales`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `TotalSalesForMovie`(movieID INT) RETURNS decimal(10,2)
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

-- -----------------------------------------------------
-- View `availableseats`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `availableseats` ;
USE `movie_ticket_sales`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `availableseats` AS select `st`.`showtime_id` AS `showtime_id`,`st`.`screen_id` AS `screen_id`,`m`.`title` AS `title`,(`scr`.`capacity` - ifnull(`bt`.`booked_tickets`,0)) AS `available_seats` from (((`showtimes` `st` join `movies` `m` on((`st`.`movie_id` = `m`.`movie_id`))) join `screens` `scr` on((`st`.`screen_id` = `scr`.`screen_id`))) left join (select `tickets`.`showtime_id` AS `showtime_id`,count(0) AS `booked_tickets` from (`tickets` join `seats` on((`tickets`.`seat_id` = `seats`.`seat_id`))) where (`seats`.`seat_status` = 'booked') group by `tickets`.`showtime_id`) `bt` on((`st`.`showtime_id` = `bt`.`showtime_id`)));

-- -----------------------------------------------------
-- View `currentmovieschedule`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `currentmovieschedule` ;
USE `movie_ticket_sales`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `currentmovieschedule` AS select `m`.`title` AS `title`,`s`.`showtime` AS `showtime`,`st`.`screen_name` AS `screen_name`,`s`.`showtime_id` AS `showtime_id` from (((`showtimes` `s` join `movies` `m` on((`s`.`movie_id` = `m`.`movie_id`))) join `screens` `scr` on((`s`.`screen_id` = `scr`.`screen_id`))) join `screentypes` `st` on((`scr`.`screen_type_id` = `st`.`screen_type_id`))) where (`s`.`showtime` > now()) order by `s`.`showtime`;

-- -----------------------------------------------------
-- View `salessummarybymovie`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `salessummarybymovie` ;
USE `movie_ticket_sales`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `salessummarybymovie` AS select `m`.`title` AS `title`,count(`t`.`ticket_id`) AS `tickets_sold`,sum(`sale`.`sale_amount`) AS `total_sales` from (((`tickets` `t` join `showtimes` `st` on((`t`.`showtime_id` = `st`.`showtime_id`))) join `movies` `m` on((`st`.`movie_id` = `m`.`movie_id`))) join `sales` `sale` on((`t`.`ticket_id` = `sale`.`ticket_id`))) group by `m`.`title`;
USE `movie_ticket_sales`;

DELIMITER $$

USE `movie_ticket_sales`$$
DROP TRIGGER IF EXISTS `PreventSoldOutSales` $$
USE `movie_ticket_sales`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `movie_ticket_sales`.`PreventSoldOutSales`
BEFORE INSERT ON `movie_ticket_sales`.`Tickets`
FOR EACH ROW
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


USE `movie_ticket_sales`$$
DROP TRIGGER IF EXISTS `RestrictLateBookings` $$
USE `movie_ticket_sales`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `movie_ticket_sales`.`RestrictLateBookings`
BEFORE INSERT ON `movie_ticket_sales`.`Tickets`
FOR EACH ROW
BEGIN
    DECLARE showTime DATETIME;
    
    -- Get the showtime
    SELECT showtime INTO showTime FROM Showtimes WHERE showtime_id = NEW.showtime_id;
    
    -- Prevent ticket booking if it's beyond 15 minutes after the showtime
    IF NOW() > DATE_ADD(showTime, INTERVAL 15 MINUTE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot booking ticket: Booking is beyond allowed time.';
    END IF;
END$$


USE `movie_ticket_sales`$$
DROP TRIGGER IF EXISTS `UpdateSalesAfterCancellation` $$
USE `movie_ticket_sales`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `movie_ticket_sales`.`UpdateSalesAfterCancellation`
AFTER DELETE ON `movie_ticket_sales`.`Tickets`
FOR EACH ROW
BEGIN
    -- Delete the corresponding sale record
    DELETE FROM Sales WHERE ticket_id = OLD.ticket_id;
END$$


USE `movie_ticket_sales`$$
DROP TRIGGER IF EXISTS `UpdateSalesAfterbooking` $$
USE `movie_ticket_sales`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `movie_ticket_sales`.`UpdateSalesAfterbooking`
AFTER INSERT ON `movie_ticket_sales`.`Tickets`
FOR EACH ROW
BEGIN
    -- Assuming ticket price is a fixed value, for simplicity
    INSERT INTO Sales (ticket_id, sale_amount) VALUES (NEW.ticket_id, 10.00); -- Example fixed price
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
