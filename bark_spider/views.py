from io import StringIO
import json
import multiprocessing.pool

from pyramid.httpexceptions import HTTPBadRequest, HTTPFound, HTTPNotFound
from pyramid.response import FileResponse, Response
from pyramid.view import view_config

from .intervention import parse_interventions, ParseError
from .json_util import DataFrameJSONEncoder
from .simulation.simulation import run_simulation

_sim_pool = multiprocessing.pool.Pool()


def _async_simulation(params, timeout=30):
    """Run a simulation asynchronously.

    Times out after `timeout` seconds, throwing a
    multiprocessing.TimeoutError if so.

    Returns a pandas DataFrame.
    """
    result = _sim_pool.apply_async(
        run_simulation,
        (params,))
    return result.get(timeout)


@view_config(route_name='root', request_method='GET')
def root(request):
    raise HTTPFound('static/index.html')


@view_config(route_name='simulate',
             request_method='POST',
             renderer='json')
def simulate_route(request):
    name = request.json_body['name']

    # We have to distinguish between a) `index params` which are used as part
    # of the index in the database and b) `run params` which contain parsed
    # interventions (and are hence not json-serializable and therefor not
    # suitable for indexing).
    index_params = request.json_body['parameters']

    run_params = index_params.copy()
    run_params['interventions'] = parse_interventions(
        StringIO(run_params['interventions']))

    try:
        name_hash, _ = request.db.add_results(
            name,
            index_params,
            lambda: _async_simulation(run_params))
    except ParseError as e:
        # Note the dissonance here. The intervention ParseError happens here
        # because of lazy parsing, while you might expect it to happen above.
        raise HTTPBadRequest(body=str(e))

    return {
        'url': request.route_url('simulation', id=name_hash),
        'result-id': name_hash,
    }


@view_config(route_name='simulation',
             request_method='GET')
def simulation_route(request):
    name_hash = request.matchdict['id']
    try:
        name, sim_params, sim_results = request.db.lookup(name_hash)
    except KeyError as e:
        raise HTTPNotFound(body="No such simulation id {}".format(e))

    results = {
        'name': name,
        'parameters': sim_params,
        'results': sim_results
    }

    return Response(
        body=json.dumps(results, cls=DataFrameJSONEncoder),
        content_type='application/json')
