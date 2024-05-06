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