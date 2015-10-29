import json
import hashlib

from pyramid.response import Response
from pyramid.view import view_config


from .json_util import DataFrameJSONEncoder
from .simulation.simulation import run_simulation


class SimulationDatabase:
    def __init__(self):
        self._names = {}  # hash(name + params) -> (name, hash(params))
        self._results = {}  # hash(params) -> (params, results)

    def add_results(self, name, params, gen):
        name_hash, params_hash = self._hash_request(name, params)
        self._names[name_hash] = (name, params_hash)

        if params_hash not in self._results:
            results = gen()
            self._results[params_hash] = (params, results)

        return (name_hash, params_hash)

    def lookup(self, name_hash):
        name, params_hash = self._names[name_hash]
        params, results = self._results[params_hash]
        return (name, params, results)


    @staticmethod
    def _hash_request(name, params):
        """Calculate the hashes for name+parameters and just the parameters.

        Args:
            name: The name associated with the simulation parameters
            params: The simulation parameters

        Returns: A tuple `(name+params hash, params hash)`.
        """
        encoded_params = json.dumps(params, sort_keys=True).encode('utf-8')
        encoded_name = name.encode('utf-8')

        return (
            hashlib.sha1(encoded_name + encoded_params).hexdigest(),
            hashlib.sha1(encoded_params).hexdigest())

# TODO: This should be part of the request, not a module scope object.
_sim_db = SimulationDatabase()


@view_config(route_name='home', renderer='templates/main_plot.pt')
def main_plot(request):
    return {'project': 'bark_spider'}


@view_config(route_name='simulate',
             request_method='POST',
             renderer='json')
def simulate_route(request):
    name = request.json_body['name']
    sim_params = request.json_body['parameters']

    name_hash, _ = _sim_db.add_results(
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
    name, sim_params, sim_results = _sim_db.lookup(name_hash)

    results = {
        'name': name,
        'parameters': sim_params,
        'results': sim_results
    }

    return Response(
        body=json.dumps(results, cls=DataFrameJSONEncoder),
        content_type='application/json')
