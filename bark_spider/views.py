from io import StringIO
import json

import pandas
from pyramid.response import Response
from pyramid.view import view_config

from brooks.brooks_law import step
from brooks.simulation import simulate

from .json_util import DataFrameJSONEncoder
from .schedule import make_schedule


@view_config(route_name='home', renderer='templates/main_plot.pt')
def main_plot(request):
    return {'project': 'bark_spider'}


def _run_simulation(params):
    attributes = ['software_development_rate']
    elapsed = params['elapsed']
    added = params['added']
    assimilation_delay = params['assimilation_delay']

    output_stream = StringIO()
    schedule = make_schedule(assimilation_delay, elapsed, added)
    simulate(schedule, step, output_stream, attributes)
    output_stream.seek(0)

    frame = pandas.read_table(output_stream)

    # This cleans up the null initial rate
    frame['software_development_rate'][0] = 0

    return frame


@view_config(route_name='simulate',
             request_method='POST')
def simulate_route(request):
    params = request.json_body['simulation_parameter_sets']
    results = {p['name']: _run_simulation(p) for p in params}
    return Response(
        body=json.dumps(results, cls=DataFrameJSONEncoder),
        content_type='application/json')
