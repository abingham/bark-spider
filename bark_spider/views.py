import json

from pyramid.response import Response
from pyramid.view import view_config


from .json_util import DataFrameJSONEncoder
from .simulation.simulation import run_simulation


@view_config(route_name='home', renderer='templates/main_plot.pt')
def main_plot(request):
    return {'project': 'bark_spider'}


@view_config(route_name='simulate',
             request_method='POST')
def simulate_route(request):
    params = request.json_body['simulation_parameter_sets']
    results = {p['name']: run_simulation(p) for p in params}
    return Response(
        body=json.dumps(results, cls=DataFrameJSONEncoder),
        content_type='application/json')
