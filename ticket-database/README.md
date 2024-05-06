# Ticket Database for Final Project

This repository contains the database setup and management scripts for the Final Project. It is designed to support a movie ticket sales system.

## Directory Structure

- **`db_submissions/`**: Contains peerceptive submissions.
  - `db_details.txt`: Brief details and notes about the database schema and configurations.
  - `db_writeup.docx`: Comprehensive documentation outlining the database schema, tables, views, stored procedures, functions, and triggers used in the project.
- **`sql_scripts/`**: Contains all SQL scripts necessary for setting up and maintaining the database.
  - **`modular_scripts/`**: Scripts for creating and initializing database components.
    - `create_procedures.sql`: Scripts to create stored procedures.
    - `create_tables.sql`: Scripts to create database tables.
    - `create_triggers.sql`: Scripts to define triggers.
    - `create_views.sql`: Scripts to create views for database reporting.
    - `define_functions.sql`: Scripts to define functions.
    - `insert_init_data.sql`: Scripts for inserting initial data into the database.
  - `ticketingDB.sql`: Main SQL script, includes comprehensive setup or maintenance routines.

## Database Schema

The database supports the ticket sales system with tables for users, customers, movies, screens, seats, showtimes, tickets, and sales. It includes procedures for booking and cancelling tickets, functions for reporting, and triggers for maintaining data integrity.

### Tables

- **Users**: Stores user account information (username, password, role).
- **Customers**: Contains customer details linked to users.
- **Movies**: Holds information such as title, director, runtime, and rating.
- **ScreenTypes**: Defines types of screens available in the theater.
- **Screens**: Details on individual screens, including type and capacity.
- **Seats**: Tracks seat numbers and status on each screen.
- **Showtimes**: Lists showtimes for movies on specific screens.
- **Tickets**: Represents tickets sold, linking showtimes, seats, and customers.
- **Sales**: Records sales transactions.

## Views and Procedures

- **Views**:
  - `availableseats`: Displays available seats for each showtime.
  - `currentmovieschedule`: Lists the current movie schedule.
  - `salessummarybymovie`: Provides a sales summary by movie.

- **Procedures**:
  - `BookTicket`: Handles ticket booking.
  - `CancelTicket`: Manages ticket cancellation.
  - `CheckSeatAvailability`: Checks seat availability for showtimes.

## Functions and Triggers

- **Functions**:
  - `IsShowtimeSoldOut`: Checks if a showtime is sold out.
  - `TicketsSoldForShowtime`: Counts tickets sold for a specific showtime.
  - `TotalSalesForMovie`: Calculates total sales for a movie.

- **Triggers**:
  - `PreventSoldOutSales`: Ensures no tickets are sold for sold-out showtimes.
  - `RestrictLateBookings`: Restricts bookings after a certain time period relative to the showtime.
  - `UpdateSalesAfterBooking`: Updates sales records post booking.
  - `UpdateSalesAfterCancellation`: Manages sales records upon ticket cancellation.

## Entity-Relationship Diagram

```mermaid
erDiagram
    USERS {
        int user_id PK
        varchar username "Unique"
        varchar password
        enum role "Default: customer"
    }
    CUSTOMERS {
        int customer_id PK
        int user_id FK "Unique"
        varchar name
        varchar email "Unique"
        varchar phone_number
    }
    MOVIES {
        int movie_id PK
        varchar title "Not Null"
        varchar director
        int runtime
        varchar rating
    }
    SCREEN_TYPES {
        int screen_type_id PK
        varchar screen_name "Not Null"
    }
    SCREENS {
        int screen_id PK
        int screen_type_id FK
        int capacity
    }
    SEATS {
        int seat_id PK
        int screen_id FK
        int seat_number
        varchar seat_status "Default: available"
    }
    SHOWTIMES {
        int showtime_id PK
        int movie_id FK
        int screen_id FK
        datetime showtime
    }
    TICKETS {
        int ticket_id PK
        int showtime_id FK
        int seat_id FK
        int customer_id FK
        timestamp booking_time "Default: CURRENT_TIMESTAMP"
    }
    SALES {
        int sale_id PK
        int ticket_id FK "Unique"
        decimal sale_amount
        timestamp sale_time "Default: CURRENT_TIMESTAMP"
    }

    USERS ||--o{ CUSTOMERS : "references"
    CUSTOMERS ||--o{ TICKETS : "references"
    MOVIES ||--o{ SHOWTIMES : "features in"
    SCREEN_TYPES ||--o{ SCREENS : "categorized by"
    SCREENS ||--o{ SEATS : "includes"
    SCREENS ||--o{ SHOWTIMES : "hosts"
    SEATS ||--o{ TICKETS : "assigned to"
    SHOWTIMES ||--o{ TICKETS : "scheduled for"
    TICKETS ||--o{ SALES : "generates"
