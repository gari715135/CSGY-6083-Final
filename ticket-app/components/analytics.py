import dash_bootstrap_components as dbc
from dash import dcc

from database.queries import QueryManager

query_manager = QueryManager()


def generate_movie_popularity_graph():
    data = query_manager.get_sales_summary_by_movie()
    return dcc.Graph(
        id='movie-popularity-graph',
        figure={
            'data': [{'x': [item['title'] for item in data],
                      'y': [item['tickets_sold'] for item in data],
                      'type': 'bar', 'name': 'Movie Popularity'}],
            'layout': {'title': 'Movie Popularity (Tickets Sold)'}
        }
    )


def generate_revenue_by_movie_graph():
    data = query_manager.get_sales_summary_by_movie()
    return dcc.Graph(
        id='sales-summary-by-movie',
        figure={
            'data': [{'x': [item['title'] for item in data],
                      'y': [item['total_sales'] for item in data],
                      'type': 'bar', 'name': 'Sales by Movie'}],
            'layout': {'title': 'Sales Summary by Movie'}
        }
    )


def analytics_section():
    return dbc.Container(fluid=True, children=[
        dbc.Row([
            dbc.Col(generate_revenue_by_movie_graph(), md=6),
            dbc.Col(generate_movie_popularity_graph(), md=6),
        ])])
