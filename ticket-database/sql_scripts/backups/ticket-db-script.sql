create schema movie_ticket_salesV2;

create table
    if not exists Movies (
        movie_id int not null,
        title varchar(255) not null,
        director varchar(255) null,
        runtime int null,
        rating varchar(50) null,
        primary key (movie_id)
    );

create table
    if not exists ScreenTypes (
        screen_type_id int auto_increment primary key,
        screen_name varchar(255) not null
    );

create table
    if not exists Screens (
        screen_id int auto_increment primary key,
        screen_type_id int not null,
        capacity int null,
        constraint screens_ibfk_1 foreign key (screen_type_id) references ScreenTypes (screen_type_id)
    );

create index screen_type_id on Screens (screen_type_id);

create table
    if not exists Seats (
        seat_id int auto_increment primary key,
        screen_id int null,
        seat_number int null,
        seat_status varchar(50) default 'available' null,
        constraint seats_ibfk_1 foreign key (screen_id) references Screens (screen_id)
    );

create index screen_id on Seats (screen_id);

create table
    if not exists Showtimes (
        showtime_id int auto_increment primary key,
        movie_id int null,
        screen_id int null,
        showtime datetime null,
        constraint showtimes_ibfk_1 foreign key (movie_id) references Movies (movie_id),
        constraint showtimes_ibfk_2 foreign key (screen_id) references Screens (screen_id)
    );

create index movie_id on Showtimes (movie_id);

create index screen_id on Showtimes (screen_id);

create table
    if not exists Users (
        user_id int auto_increment primary key,
        username varchar(255) null,
        password varchar(255) null,
        role enum ('customer', 'admin') default 'customer' null,
        constraint username unique (username)
    );

create table
    if not exists Customers (
        customer_id int auto_increment primary key,
        user_id int null,
        name varchar(255) null,
        email varchar(255) null,
        phone_number varchar(50) null,
        constraint email unique (email),
        constraint user_id unique (user_id),
        constraint customers_ibfk_1 foreign key (user_id) references Users (user_id)
    );

create table
    if not exists Tickets (
        ticket_id int auto_increment primary key,
        showtime_id int null,
        seat_id int null,
        customer_id int null,
        booking_time timestamp default CURRENT_TIMESTAMP null,
        constraint tickets_ibfk_1 foreign key (showtime_id) references Showtimes (showtime_id),
        constraint tickets_ibfk_2 foreign key (seat_id) references Seats (seat_id),
        constraint tickets_ibfk_3 foreign key (customer_id) references Customers (customer_id)
    );

create table
    if not exists Sales (
        sale_id int auto_increment primary key,
        ticket_id int null,
        sale_amount decimal(10, 2) null,
        sale_time timestamp default CURRENT_TIMESTAMP null,
        constraint ticket_id unique (ticket_id),
        constraint sales_ibfk_1 foreign key (ticket_id) references Tickets (ticket_id)
    );

create index customer_id on Tickets (customer_id);

create index seat_id on Tickets (seat_id);

create index showtime_id on Tickets (showtime_id);

create trigger PreventSoldOutSales before insert on Tickets for each row BEGIN DECLARE showCapacity INT;

DECLARE ticketsSold INT;

-- Get the total capacity of the screen
SELECT
    capacity INTO showCapacity
FROM
    Screens scr
    JOIN Showtimes st ON scr.screen_id = st.screen_id
WHERE
    st.showtime_id = NEW.showtime_id;

-- Get the number of tickets already sold
SELECT
    COUNT(*) INTO ticketsSold
FROM
    Tickets
WHERE
    showtime_id = NEW.showtime_id;

-- Prevent insert if the show is sold out
IF ticketsSold >= showCapacity THEN SIGNAL SQLSTATE '45000'
SET
    MESSAGE_TEXT = 'Cannot sell ticket: Show is sold out.';

END IF;

END;

create trigger RestrictLateBookings before insert on Tickets for each row BEGIN DECLARE showTime DATETIME;

-- Get the showtime
SELECT
    showtime INTO showTime
FROM
    Showtimes
WHERE
    showtime_id = NEW.showtime_id;

-- Prevent ticket booking if it's beyond 15 minutes after the showtime
IF NOW () > DATE_ADD (showTime, INTERVAL 15 MINUTE) THEN SIGNAL SQLSTATE '45000'
SET
    MESSAGE_TEXT = 'Cannot booking ticket: Booking is beyond allowed time.';

END IF;

END;

create trigger UpdateSalesAfterCancellation after delete on Tickets for each row BEGIN
-- Delete the corresponding sale record
DELETE FROM Sales
WHERE
    ticket_id = OLD.ticket_id;

END;

create trigger UpdateSalesAfterbooking after insert on Tickets for each row BEGIN
-- Assuming ticket price is a fixed value, for simplicity
INSERT INTO
    Sales (ticket_id, sale_amount)
VALUES
    (NEW.ticket_id, 10.00);

-- Example fixed price
END;

create
or replace view availableseats as
select
    `st`.`showtime_id` AS `showtime_id`,
    `st`.`screen_id` AS `screen_id`,
    `m`.`title` AS `title`,
    (
        `scr`.`capacity` - ifnull (`bt`.`booked_tickets`, 0)
    ) AS `available_seats`
from
    (
        (
            (
                `movie_ticket_sales`.`showtimes` `st`
                join `movie_ticket_sales`.`movies` `m` on ((`st`.`movie_id` = `m`.`movie_id`))
            )
            join `movie_ticket_sales`.`screens` `scr` on ((`st`.`screen_id` = `scr`.`screen_id`))
        )
        left join (
            select
                `movie_ticket_sales`.`tickets`.`showtime_id` AS `showtime_id`,
                count(0) AS `booked_tickets`
            from
                (
                    `movie_ticket_sales`.`tickets`
                    join `movie_ticket_sales`.`seats` on (
                        (
                            `movie_ticket_sales`.`tickets`.`seat_id` = `movie_ticket_sales`.`seats`.`seat_id`
                        )
                    )
                )
            where
                (
                    `movie_ticket_sales`.`seats`.`seat_status` = 'booked'
                )
            group by
                `movie_ticket_sales`.`tickets`.`showtime_id`
        ) `bt` on ((`st`.`showtime_id` = `bt`.`showtime_id`))
    );

create
or replace view currentmovieschedule as
select
    `m`.`title` AS `title`,
    `s`.`showtime` AS `showtime`,
    `st`.`screen_name` AS `screen_name`,
    `s`.`showtime_id` AS `showtime_id`
from
    (
        (
            (
                `movie_ticket_sales`.`showtimes` `s`
                join `movie_ticket_sales`.`movies` `m` on ((`s`.`movie_id` = `m`.`movie_id`))
            )
            join `movie_ticket_sales`.`screens` `scr` on ((`s`.`screen_id` = `scr`.`screen_id`))
        )
        join `movie_ticket_sales`.`screentypes` `st` on ((`scr`.`screen_type_id` = `st`.`screen_type_id`))
    )
where
    (`s`.`showtime` > now ())
order by
    `s`.`showtime`;

create
or replace view salessummarybymovie as
select
    `m`.`title` AS `title`,
    count(`t`.`ticket_id`) AS `tickets_sold`,
    sum(`sale`.`sale_amount`) AS `total_sales`
from
    (
        (
            (
                `movie_ticket_sales`.`tickets` `t`
                join `movie_ticket_sales`.`showtimes` `st` on ((`t`.`showtime_id` = `st`.`showtime_id`))
            )
            join `movie_ticket_sales`.`movies` `m` on ((`st`.`movie_id` = `m`.`movie_id`))
        )
        join `movie_ticket_sales`.`sales` `sale` on ((`t`.`ticket_id` = `sale`.`ticket_id`))
    )
group by
    `m`.`title`;

create procedure BookTicket (
    IN customerID int,
    IN showtimeID int,
    IN seatID int
) BEGIN DECLARE seatAvailable VARCHAR(50);

-- Check if the seat is available
SELECT
    seat_status INTO seatAvailable
FROM
    Seats
WHERE
    seat_id = seatID;

IF seatAvailable = 'available' THEN
-- Insert ticket information
INSERT INTO
    Tickets (showtime_id, seat_id, customer_id)
VALUES
    (showtimeID, seatID, customerID);

-- Update seat status to 'booked'
UPDATE Seats
SET
    seat_status = 'booked'
WHERE
    seat_id = seatID;

SELECT
    'Ticket booked Successfully' AS Result;

ELSE
SELECT
    'Seat Not Available' AS Result;

END IF;

END;

create procedure CancelTicket (IN ticketID int) BEGIN DECLARE seatID INT;

-- Find the seat ID associated with the ticket
SELECT
    seat_id INTO seatID
FROM
    Tickets
WHERE
    ticket_id = ticketID;

-- Update seat status back to 'available'
UPDATE Seats
SET
    seat_status = 'available'
WHERE
    seat_id = seatID;

DELETE FROM Sales
WHERE
    ticket_id = ticketID;

DELETE FROM Tickets
WHERE
    ticket_id = ticketID;

SELECT
    'Ticket Canceled Successfully' AS Result;

END;

create procedure CheckSeatAvailability (IN showtimeID int) BEGIN
SELECT
    s.seat_id,
    s.seat_number,
    s.seat_status
FROM
    Seats s
    JOIN Showtimes st ON s.screen_id = st.screen_id
WHERE
    st.showtime_id = showtimeID
    AND s.seat_id NOT IN (
        SELECT
            t.seat_id
        FROM
            Tickets t
        WHERE
            t.showtime_id = showtimeID
    )
    AND s.seat_status = 'available';

END;

create procedure GenerateSeatsForScreen (IN screenId int, IN screenCapacity int) BEGIN DECLARE seatNumber INT DEFAULT 0;

-- Loop to insert seats up to the screenCapacity
WHILE seatNumber < screenCapacity DO
SET
    seatNumber = seatNumber + 1;

-- Insert the seat into the Seats table
INSERT INTO
    Seats (screen_id, seat_number, seat_status)
VALUES
    (screenId, seatNumber, 'available');

END WHILE;

END;

create function IsShowtimeSoldOut (showtimeID int) returns varchar(5) BEGIN DECLARE capacity INT;

DECLARE ticketsSold INT;

-- Get the screen capacity for the showtime
SELECT
    scr.capacity INTO capacity
FROM
    Screens scr
    JOIN Showtimes st ON scr.screen_id = st.screen_id
WHERE
    st.showtime_id = showtimeID;

-- Get the number of tickets sold
SET
    ticketsSold = TicketsSoldForShowtime (showtimeID);

-- Check if the showtime is sold out
IF capacity <= ticketsSold THEN RETURN 'Yes';

ELSE RETURN 'No';

END IF;

END;

create function TicketsSoldForShowtime (showtimeID int) returns int BEGIN DECLARE ticketsSold INT;

SELECT
    COUNT(*) INTO ticketsSold
FROM
    Tickets
WHERE
    showtime_id = showtimeID;

RETURN ticketsSold;

END;

create function TotalSalesForMovie (movieID int) returns decimal(10, 2) reads sql data BEGIN DECLARE totalSales DECIMAL(10, 2) DEFAULT 0;

SELECT
    SUM(s.sale_amount) INTO totalSales
FROM
    Sales s
    JOIN Tickets t ON s.ticket_id = t.ticket_id
    JOIN Showtimes st ON t.showtime_id = st.showtime_id
WHERE
    st.movie_id = movieID;

RETURN IFNULL (totalSales, 0);

END;