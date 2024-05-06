# Final Project: Movie Ticket Sales System

This repository hosts the complete source code and database setup for a movie ticket sales system. It comprises two main parts: the application code (`ticket-app`) and the database scripts (`ticket-database`).

## Repository Structure

- **`ticket-app/`**: Contains all the source code for the movie ticket sales application.
  - [Read detailed README](./ticket-app/README.md)
- **`ticket-database/`**: Contains all SQL scripts and database documentation necessary to set up and maintain the movie ticket sales database.
  - [Read detailed README](./ticket-database/README.md)

## ticket-app

### Overview

This application provides a web-based interface for managing movie ticket sales, built with Flask, Dash, and Dash Bootstrap Components, integrating with a MySQL database to perform operations like displaying analytics, managing ticket sales, and querying real-time seat availability.

### Key Components

- **Flask server and Dash app**: Core of the web application.
- **Database interaction**: Managed through custom classes for connection and query execution.
- **Components for business logic**: Includes ticket management and analytics.

### Features

- **Analytics Dashboard**: For visualizing movie popularity and sales data.
- **Real-time Database Interaction**: For up-to-date information on bookings and seat availability.

## ticket-database

### Overview

Houses the SQL scripts and detailed documentation for setting up the database that supports the ticket sales application.

### Key Elements

- **Schema setup and management**: Scripts to create and update the database schema.
- **Procedures and triggers**: For handling business logic at the database level.

### Database Components

- **Tables**: For storing users, tickets, movies, and other relevant data.
- **Views and Procedures**: For enhanced data retrieval and manipulation.

## How to Use This Repository

1. **Set up the database**: Navigate to the `ticket-database` directory and follow the instructions to create and populate the database.
2. **Run the application**: Go to the `ticket-app` directory, set up the environment, and start the server as per the instructions.

## Contributing

Contributions to the project are welcome. Please refer to the README files in the respective directories for more detailed information on the project structure and guidelines for contributing.

For a full description of the project's functionality and architecture, please refer to the README files in the individual directories.
