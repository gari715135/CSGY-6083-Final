
-- Insert into Users
INSERT INTO Users (username, password, role) VALUES
('customer1', 'pass123', 'customer'),
('customer2', 'pass124', 'customer');

-- Insert into Customers
INSERT INTO Customers (user_id, name, email, phone_number) VALUES
(1, 'John Doe', 'johndoe@example.com', '123-456-7890'),
(2, 'Jane Smith', 'janesmith@example.com', '098-765-4321');

-- Insert into Screen_Types
INSERT INTO ScreenTypes(screen_name) VALUES
("IMAX"), ("Premium"), ("Standard");

INSERT INTO Screens (screen_type_id, capacity) VALUES
((SELECT screen_type_id FROM ScreenTypes WHERE screen_name = 'IMAX'), 5),
((SELECT screen_type_id FROM ScreenTypes WHERE screen_name = 'Premium'), 4),
((SELECT screen_type_id FROM ScreenTypes WHERE screen_name = 'Standard'), 3);

CALL GenerateSeatsForScreen(1, 5);
CALL GenerateSeatsForScreen(2, 4);
CALL GenerateSeatsForScreen(3, 3);