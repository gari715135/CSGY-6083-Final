import os
import pymysql.cursors
from dotenv import load_dotenv
from threading import Lock

db_lock = Lock()


class DatabaseConnector:
    def __init__(self):
        load_dotenv()
        self.connection = pymysql.connect(
            host=os.getenv('DB_HOST'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            db=os.getenv('DB_NAME'),
            cursorclass=pymysql.cursors.DictCursor
        )
        self.cursor = self.connection.cursor()

    def execute_query(self, query, params=None):
        db_lock.acquire()
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
            self.connection.commit()
            return self.cursor.fetchall()
        except Exception as e:
            print(f"Error executing query: {e}\nQuery: {query}\nParams: {params}")
            self.connection.rollback()
            return []
        finally:
            db_lock.release()

    def close(self):
        self.connection.close()
