import json
import uuid

from pyramid.response import Response
from pyramid.view import view_config


from .json_util import DataFrameJSONEncoder
from .simulation.simulation import run_simulation

# Our results "database". Sure to be replaced with a real one soon
# enough...
_simulation_results = {}


@view_config(route_name='home', renderer='templates/main_plot.pt')
def main_plot(request):
    return {'project': 'bark_spider'}


@view_config(route_name='simulate',
             request_method='POST',
             renderer='json')
def simulate_route(request):
    global _simulation_results

    params = request.json_body
    results = run_simulation(params)

    # TODO: Use hash of parameters instead.
    # TODO: If hash already in results, short-circuit
    results_id = str(uuid.uuid1())
    _simulation_results[results_id] = {
        'parameters': params,
        'results': results,
    }

    return {
        'url': request.route_url('simulation', id=results_id),
    }


@view_config(route_name='simulation',
             request_method='GET')
def simulation_route(request):
    simulation_id = request.matchdict['id']
    results = _simulation_results[simulation_id]
    return Response(
        body=json.dumps(results, cls=DataFrameJSONEncoder),
        content_type='application/json')
