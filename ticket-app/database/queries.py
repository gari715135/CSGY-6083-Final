from .db_connector import DatabaseConnector


class QueryManager:
    def __init__(self):
        self.db = DatabaseConnector()

    def get_sales_summary_by_movie(self):
        query = "SELECT * FROM salessummarybymovie;"
        return self.db.execute_query(query)

    def get_available_seat_count(self):
        query = "SELECT * FROM availableseats"
        return self.db.execute_query(query)

    def get_current_schedule(self):
        query = "SELECT * FROM currentmovieschedule"
        return self.db.execute_query(query)

    def get_available_seats(self, showtime_id):
        query = "CALL CheckSeatAvailability(%s);"
        return self.db.execute_query(query, (showtime_id,))

    def purchase_ticket(self, customer_id, showtime_id, seat_id):
        try:
            query = "CALL BookTicket(%s, %s, %s);"
            self.db.execute_query(query, (customer_id, showtime_id, seat_id))
            self.db.connection.commit()
            return True, "Ticket purchased successfully."
        except Exception as e:
            self.db.connection.rollback()
            return False, f"Error purchasing ticket: {e}"

    def cancel_ticket(self, ticket_id):
        try:
            query = "CALL CancelTicket(%s);"
            self.db.execute_query(query, (ticket_id,))
            self.db.connection.commit()
            return True, "Ticket cancelled successfully."
        except Exception as e:
            self.db.connection.rollback()
            return False, f"Error cancelling ticket: {e}"

    def get_tickets_for_showtime(self, showtime_id):
        query = """
        SELECT t.ticket_id, s.seat_number 
        FROM Tickets t
        JOIN Seats s ON t.seat_id = s.seat_id
        WHERE t.showtime_id = %s;
        """
        return self.db.execute_query(query, (showtime_id,))

    def change_ticket_seat(self, ticket_id, new_seat_id):
        """
        Update the seat for a specific ticket.
        """
        query = "UPDATE Tickets SET seat_id = %s WHERE ticket_id = %s;"
        try:
            self.db.execute_query(query, (new_seat_id, ticket_id))
            return True, "Seat updated successfully."
        except Exception as e:
            return False, f"Error updating seat: {e}"

    def __del__(self):
        self.db.close()
