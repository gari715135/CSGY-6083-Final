import datetime
import os
import random

import mysql.connector
import pandas as pd
import requests
from mysql.connector import Error
from database.queries import QueryManager

def get_credits(movie_id, api_key="a5609d786597198efea7fb1df446b4df"):
    base_url = "https://api.themoviedb.org/3/movie"
    url = base_url + "/{}/credits?api_key={}".format(movie_id, api_key)
    resp = requests.get(url).json()
    return resp


def get_details(movie_id, api_key="a5609d786597198efea7fb1df446b4df"):
    base_url = "https://api.themoviedb.org/3/movie"
    url = base_url + "/{}?api_key={}".format(movie_id, api_key)
    resp = requests.get(url).json()
    return resp


def get_rating(movie_id, api_key="a5609d786597198efea7fb1df446b4df"):
    base_url = 'https://api.themoviedb.org/3/movie'
    url = base_url + '/{}/release_dates?api_key={}'.format(movie_id, api_key)
    resp = requests.get(url).json()
    return resp


def concatenate_results(pages):
    all_results = []

    for page in pages:
        if not isinstance(page, int):
            page_results = page["results"]
            all_results.extend(page_results)

    return all_results


def get_movie_data(movie_ids, api_key="a5609d786597198efea7fb1df446b4df"):
    movies_data = []  # To hold the data for each movie

    for movie_id in movie_ids:
        try:
            # Initialize dictionary to hold movie data
            movie_dict = {"title": None, "director": None, "runtime": None, "rating": 'NR'}

            # Get movie details
            details = get_details(movie_id, api_key)

            movie_dict["title"] = details.get("title")
            movie_dict["runtime"] = details.get("runtime")

            # Get director name
            film_credits = get_credits(movie_id, api_key)
            crew_df = pd.DataFrame(film_credits.get("crew"))
            director = crew_df[crew_df['job'].str.lower() == 'director']['name'].iloc[0] if not crew_df.empty else None
            movie_dict["director"] = director

            ratings = get_rating(movie_id, api_key)
            ratings_df = pd.DataFrame(ratings['results'])
            us = ratings_df[ratings_df['iso_3166_1'] == 'US']
            try:
                rating = us.explode('release_dates')['release_dates'].apply(
                    lambda x: x["certification"])
                rating = rating[rating != '']
                if len(rating) >= 1:
                    rating = rating.values[0]
                else:
                    rating = "N/R"
            except:
                rating = None
            movie_dict['rating'] = rating
            movie_dict["id"] = movie_id

            # Add the dictionary to the list
            movies_data.append(movie_dict)

        except IndexError:
            print("index error for id {}".format(movie_id))
            pass

    return pd.DataFrame(movies_data)

def connect_to_db():
    try:
        conn = mysql.connector.connect(
            host='localhost',
            database='movie_ticket_sales',
            user='root',
            password='Enzo0602'
        )
        if conn.is_connected():
            print('Connected to MySQL database')
            return conn
    except Error as e:
        print(e)

def insert_initial_data():
    query_manager = QueryManager()

    # Insert into Users
    users_insert = """
    INSERT INTO Users (username, password, role)
    VALUES 
        ('customer1', 'pass123', 'customer'),
        ('customer2', 'pass124', 'customer'),
        ('manager2', 'pass123', 'admin');
    """
    query_manager.db.execute_query(users_insert)

    # Insert into Customers
    customers_insert = """
    INSERT INTO Customers (user_id, name, email, phone_number)
    VALUES
        (1, 'John Doe', 'johndoe@example.com', '123-456-7890'),
        (2, 'Jane Smith', 'janesmith@example.com', '098-765-4321');
    """
    query_manager.db.execute_query(customers_insert)

    # Insert into ScreenTypes and generate seats
    screen_types_insert = """
    INSERT INTO ScreenTypes (screen_name)
    VALUES ('IMAX'), ('Premium'), ('Standard');
    """
    query_manager.db.execute_query(screen_types_insert)

    screens_insert = """
    INSERT INTO Screens (screen_type_id, capacity)
    VALUES 
        ((SELECT screen_type_id FROM ScreenTypes WHERE screen_name = 'IMAX'), 5),
        ((SELECT screen_type_id FROM ScreenTypes WHERE screen_name = 'Premium'), 4),
        ((SELECT screen_type_id FROM ScreenTypes WHERE screen_name = 'Standard'), 3);
    """
    query_manager.db.execute_query(screens_insert)

    query_manager.db.execute_query("CALL GenerateSeatsForScreen(1, 5)")
    query_manager.db.execute_query("CALL GenerateSeatsForScreen(2, 4)")
    query_manager.db.execute_query("CALL GenerateSeatsForScreen(3, 3)")

    print("Initial data inserted successfully.")

def insert_random_ticket_sales():
    query_manager = QueryManager()

    try:
        # Insert random ticket sales
        showtimes = query_manager.db.execute_query("SELECT showtime_id, screen_id FROM Showtimes")

        for showtime in showtimes:
            showtime_id = showtime['showtime_id']
            screen_id = showtime['screen_id']

            capacity = query_manager.db.execute_query("SELECT capacity FROM Screens WHERE screen_id = %s", (screen_id,))[0]['capacity']

            # Randomly determine the number of tickets to sell (up to 50% of the screen capacity)
            num_tickets = random.randint(0, capacity // 2)

            available_seats = query_manager.get_available_seats(showtime_id)

            for _ in range(num_tickets):
                if available_seats:
                    seat = random.choice(available_seats)
                    seat_id = seat['seat_id']
                   # available_seats = [seat for seat in available_seats if seat[0] != seat_id]

                    # Randomly select a customer
                    customer_ids = [customer['customer_id'] for customer in query_manager.db.execute_query("SELECT customer_id FROM Customers")]
                    customer_id = random.choice(customer_ids)

                    # Book the ticket using the BookTicket procedure
                    query_manager.purchase_ticket(customer_id, showtime_id, seat_id)
                    print(f"Booking ticket for customer {customer_id}, showtime {showtime_id}, seat {seat_id}")

        print("Random ticket sales inserted successfully.")

    except Exception as e:
        print(f"Error occurred while inserting random ticket sales: {str(e)}")

# Function to insert movies
def insert_movies(movies_data):
    query_manager = QueryManager()

    query = """INSERT INTO Movies (movie_id, title, director, runtime, rating) 
               VALUES (%s, %s, %s, %s, %s) ON DUPLICATE KEY UPDATE 
               title=VALUES(title), director=VALUES(director), runtime=VALUES(runtime), rating=VALUES(rating)"""
    for index, row in movies_data.iterrows():
        query_manager.db.execute_query(query, (row['id'], row['title'], row['director'], row['runtime'], row['rating']))
    print("Movies inserted successfully")

def generate_and_insert_showtimes(start_date, end_date, movie_ids):
    query_manager = QueryManager()

    # Define operating hours and showtime intervals
    operating_hours = range(10, 22, 4)
    screens = [1, 2, 3]  # Screen IDs

    start = datetime.datetime.strptime(start_date, '%Y-%m-%d')
    end = datetime.datetime.strptime(end_date, '%Y-%m-%d')
    date_generated = [start + datetime.timedelta(days=x) for x in range((end - start).days + 1)]

    for date in date_generated:
        for hour in operating_hours:
            # Select 3 random movies for each showtime
            selected_movie_ids = random.sample(movie_ids, 3)
            for screen_id, movie_id in zip(screens, selected_movie_ids):
                showtime_str = date.replace(hour=hour).strftime('%Y-%m-%d %H:%M:%S')
                insert_query = """INSERT INTO Showtimes (movie_id, screen_id, showtime) 
                                  VALUES (%s, %s, %s)"""
                query_manager.db.execute_query(insert_query, (movie_id, screen_id, showtime_str))

# Prepare movie data

movies_file = './movies_data.csv'
if os.path.exists(movies_file):
    movies_data = pd.read_csv(movies_file)
    movies_data["id"] = movies_data["id"].astype(int)
else:
    api_key = "a5609d786597198efea7fb1df446b4df"
    api_access_token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhNTYwOWQ3ODY1OTcxOThlZmVhN2ZiMWRmNDQ2YjRkZiIsInN1YiI6IjYzMDdmOTg1MTg4NjRiMDA3YjE4YzY2ZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.85EbSelFus-ROLOzDYVBqdc4jSC__mDTjltqv1tMhlk"

    responses = [0, 0]
    for page in range(1, 3):
        url = "https://api.themoviedb.org/3/movie/now_playing?language=en-US&page={}&region=US".format(
            page
        )

        headers = {
            "accept": "application/json",
            "Authorization": f"Bearer {api_access_token}",
        }

    response = requests.get(url, headers=headers)
    responses[page - 1] = response.json()

    movie_df = pd.DataFrame(concatenate_results(responses))
    movies_data = get_movie_data(movie_df['id'].tolist())
    movies_data.to_csv(movies_file, index=False)

insert_initial_data()

# Fill nulls
movies_data = movies_data.fillna("Unavailable")

# Insert movies
insert_movies(movies_data)

start_date = '2024-05-05'
end_date = '2024-05-10'
generate_and_insert_showtimes(start_date, end_date, movies_data['id'].tolist())

# Insert random ticket sales
insert_random_ticket_sales()