import json

from pyramid.response import Response
from pyramid.view import view_config


from .json_util import DataFrameJSONEncoder
from .simulation.simulation import run_simulation


@view_config(route_name='home', renderer='templates/main_plot.pt')
def main_plot(request):
    return {'project': 'bark_spider'}


@view_config(route_name='simulate',
             request_method='POST',
             renderer='json')
def simulate_route(request):
    name = request.json_body['name']
    sim_params = request.json_body['parameters']

    name_hash, _ = request.db.add_results(
        name,
        sim_params,
        lambda: run_simulation(sim_params))

    return {
        'url': request.route_url('simulation', id=name_hash),
        'result-id': name_hash,
    }


@view_config(route_name='simulation',
             request_method='GET')
def simulation_route(request):
    name_hash = request.matchdict['id']
    name, sim_params, sim_results = request.db.lookup(name_hash)

    results = {
        'name': name,
        'parameters': sim_params,
        'results': sim_results
    }

    return Response(
        body=json.dumps(results, cls=DataFrameJSONEncoder),
        content_type='application/json')
