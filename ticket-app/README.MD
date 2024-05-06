# Movie Ticket Sales App

## Overview

This application provides a web-based interface for managing movie ticket sales. Built with Flask, Dash, and Dash Bootstrap Components, the system integrates with a MySQL database to perform various operations like displaying analytics, managing ticket sales, and querying real-time seat availability.

## Project Structure

The project consists of several Python files organized into directories for components, database interaction, and the main server application. Here's an outline of the key files:

- `app.py` - Initializes the Flask server and Dash app, defining the application's layout and routing.
- `./database/db_connector.py` - Contains the `DatabaseConnector` class for database connection and query execution.
- `./database/queries.py` - Defines the `QueryManager` class for executing specific database queries related to ticket sales and showtimes.
- `./components/ticket_management.py` - Manages the ticket purchasing and cancellation functionalities within the dashboard.
- `./components/analytics.py` - Provides functions to generate graphical analytics about movie popularity and revenue.

## Features

- **Analytics Dashboard**: Displays movie popularity and sales data through interactive graphs.
- **Ticket Management**: Supports ticket booking and cancellation, along with displaying current bookings and seat availability.
- **Real-time Database Interaction**: Uses stored procedures and dynamic queries for real-time data retrieval and updates.

## Installation

### Prerequisites

- Python 3.8 or later
- Flask
- Dash and Dash Bootstrap Components
- pymysql
- python-dotenv

To install the required Python packages:

```bash
pip install -r requirements.txt
```

### Environment Setup

Create a `.env` file in the root directory and add your database credentials:

```
DB_HOST=localhost
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=movie_ticket_sales
```

## Running the Server

To start the server, run:

```bash
python app.py
```

This will start the Flask server with the Dash application accessible via `http://localhost:8050/`.

## SQL Scripts

Included SQL scripts in the `./sql_queries` directory facilitate the creation of views and stored procedures necessary for the application functionalities.