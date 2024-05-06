from flask import Flask
import dash
from dash import html, dcc, Input, Output
import dash_bootstrap_components as dbc
from components.analytics import analytics_section
from components.ticket_management import ticket_management_section

# Initialize Flask server
server = Flask(__name__)

# External stylesheet
external_stylesheets = [dbc.themes.BOOTSTRAP, 'https://codepen.io/chriddyp/pen/bWLwgP.css']

def create_dashboard_layout(server):
    """
    Create the layout for the dashboard.
    """
    app = dash.Dash(__name__, server=server, external_stylesheets=external_stylesheets, routes_pathname_prefix='/',
                    suppress_callback_exceptions=True)
    # App layout with navigation tabs
    app.layout = html.Div([
        dcc.Location(id='url', refresh=True),  # Add the Location component
        html.Div(id='page-content'),  # Placeholder for page content
        dcc.Tabs(id="tabs", value='tab-1', children=[
            dcc.Tab(label='Dashboard Analytics', value='tab-1'),
            dcc.Tab(label='Ticket Purchase', value='tab-2'),
        ], className='nav nav-pills'),
        html.Div(id='tabs-content')
    ])

    @app.callback(Output('tabs-content', 'children'),
                  [Input('tabs', 'value')])
    def render_content(tab):
        if tab == 'tab-1':
            return analytics_section()
        elif tab == 'tab-2':
            return ticket_management_section()

    return app

app = create_dashboard_layout(server)

if __name__ == '__main__':
    app.run_server(debug=True)
