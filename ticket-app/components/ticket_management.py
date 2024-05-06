from dash import dcc, html, callback, callback_context, Input, Output, State
import dash_bootstrap_components as dbc
from dash.dash_table import DataTable
from database.queries import QueryManager
import logging

logging.basicConfig(filename='app.log', filemode='w', format='%(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)

# Initialize QueryManager
query_manager = QueryManager()


def ticket_management_section():
    """Constructs the ticket management section with dynamic movie selection and full CRUD operations on tickets, including viewing, cancelling, and modifying seats."""
    return html.Div([
        dbc.Row(html.H2("Ticket Management")),
        dbc.Row([
            dbc.Col([
                dcc.Dropdown(
                    id='movie-showtime-dropdown',
                    options=[],
                    placeholder='Select a movie and showtime',
                ),
                dcc.Checklist(
                    id="seat-selection-checklist",
                    options=[],
                    value=[],
                    inline=True,
                ),
            ], width=6),
            dbc.Col(html.Div(id='seat-selection-area'), width=6),
        ]),
        dbc.Row([
            DataTable(
                id='tickets-table',
                columns=[
                    {"name": "Ticket ID", "id": "ticket_id"},
                    {"name": "Seat Number", "id": "seat_number"},
                ],
                data=[],
                row_selectable="single",
                selected_rows=[],
                style_table={'height': '300px', 'overflowY': 'auto'},
                markdown_options={"html": True},
            )
        ]),
        dbc.Row([
            dbc.Col([
                dbc.Button("Purchase Ticket", id="purchase-ticket-button", color="success", className="mr-2"),
                dbc.Button("Cancel Selected Ticket", id="cancel-selected-ticket-button", color="danger",
                           className="mr-2"),
                dbc.Button("Modify Selected Ticket Seat", id="modify-selected-ticket-seat-button", color="primary",
                           className="mr-2"),
            ], width=6),
        ]),
        html.Div(id='ticket-management-feedback')
    ])


@callback(
    Output('movie-showtime-dropdown', 'options'),
    Input('movie-showtime-dropdown', 'n_intervals')
)
def update_movie_showtime_dropdown(n):
    schedule = query_manager.get_current_schedule()
    return [{'label': f"{item['title']} - {item['showtime'].strftime('%Y-%m-%d %H:%M:%S')} - {item['screen_name']}",
             'value': item['showtime_id']} for item in schedule]


@callback(
    Output('seat-selection-area', 'children'),
    Input('movie-showtime-dropdown', 'value')
)
def update_seat_selection(showtime_id):
    if showtime_id:
        available_seats = query_manager.get_available_seats(showtime_id)
        return dbc.Row([
            dbc.Label("Select Seat"),
            dcc.Checklist(
                options=[{'label': f"Seat {seat['seat_number']}", 'value': seat['seat_id']} for seat in
                         available_seats],
                value=[],
                id="seat-selection-checklist",
                inline=True,
            ),
        ])
    return "Please select a showtime to see available seats."


@callback(
    Output('tickets-table', 'data'),
    Input('movie-showtime-dropdown', 'value')
)
def update_tickets_table(showtime_id):
    if not showtime_id:
        logging.info('No showtime ID provided.')
        return []
    tickets = query_manager.get_tickets_for_showtime(showtime_id)
    if tickets:
        data = [{'ticket_id': ticket['ticket_id'], 'seat_number': ticket['seat_number']}
                for ticket in tickets]
        logging.info(f'Found tickets for showtime ID {showtime_id}: {tickets}')
    else:
        data = []
    return data


@callback(
    Output('ticket-management-feedback', 'children'),
    [Input('purchase-ticket-button', 'n_clicks'), Input('cancel-selected-ticket-button', 'n_clicks'),
     Input('modify-selected-ticket-seat-button', 'n_clicks')],
    [State('movie-showtime-dropdown', 'value'), State('seat-selection-checklist', 'value'),
     State('tickets-table', 'selected_rows'), State('tickets-table', 'data')]
)
def handle_ticket_actions(purchase_clicks, cancel_selected_clicks, modify_selected_clicks, showtime_id, selected_seats,
                          selected_rows, tickets_data):
    ctx = callback_context
    triggered_id = ctx.triggered[0]['prop_id'].split('.')[0]

    if triggered_id == 'purchase-ticket-button':
        if not showtime_id or not selected_seats:
            return 'Please select a showtime and at least one seat to proceed with the purchase.'
        customer_id = 1
        for selected_seat in selected_seats:
            success, message = query_manager.purchase_ticket(customer_id, showtime_id, selected_seat)

        return message
    elif triggered_id == 'cancel-selected-ticket-button':
        if not selected_rows:
            return "No ticket selected for cancellation."
        ticket_id = tickets_data[selected_rows[0]]['ticket_id']
        success, message = query_manager.cancel_ticket(ticket_id)
        return message
    elif triggered_id == 'modify-selected-ticket-seat-button':
        if not selected_rows or not selected_seats:
            return "Please select a ticket and a new seat to modify."
        ticket_id = tickets_data[selected_rows[0]]['ticket_id']
        new_seat_id = selected_seats[0]
        success, message = query_manager.change_ticket_seat(ticket_id, new_seat_id)
        return message
    return "No action taken."