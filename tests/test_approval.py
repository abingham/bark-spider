"""Tests for the bark-spider JSON API.

These are essentially approval tests.

* fix the code that causes the tests to fail, or
* update the tests to reflect the new notion of correct

In other words, these are tests to detect that we've noticed that our
JSON data has changed.

"""
import json

from bark_spider.app import make_app
from bark_spider.json_util import DataFrameJSONEncoder
from bark_spider.simulation.simulation import run_simulation
from bark_spider.simulation_db import SimulationDatabase
import pytest

# TODO: We should probably use Hypothesis to generate this test data

TEST_DATA = [
    {'name': 'test params',
     'parameters': {
         'assimilation_delay': 20,
         'training_overhead_proportion': 0.25,
         'interventions': '',
         'num_function_points_requirements': 10
     }
     },

    {'name': 'test params1',
     'parameters': {
         'assimilation_delay': 20,
         'training_overhead_proportion': 0.25,
         'interventions': '',
         'num_function_points_requirements': 5
     }
     },
]

MALFORMED_INTERVENTION_REQUEST = {
    'name': 'test params',
    'parameters': {
        'assimilation_delay': 20,
        'training_overhead_proportion': 0.25,
        'interventions': 'no_timestamp_provided',
        'num_function_points_requirements': 10
    }}

UNKNOWN_INTERVENTION_REQUEST = {
    'name': 'test params',
    'parameters': {
        'assimilation_delay': 20,
        'training_overhead_proportion': 0.25,
        'interventions': 'no_such_intervention_i_hope 1234',
        'num_function_points_requirements': 10
    }}

async def test_get_root(test_client, loop):
    app = make_app(loop=loop)
    client = await test_client(app)
    resp = await client.get('/')
    assert resp.status == 200


@pytest.fixture
def cli(loop, test_client):
    app = make_app(loop=loop)
    return loop.run_until_complete(test_client(app))


async def test_simulate_route(cli):
    for req_data in TEST_DATA:
        # Unpack the initial values
        simulation_name = req_data['name']
        simulation_parameters = req_data['parameters']

        # Determine the expected results by calling the simulator directly
        expected_simulation_results_frame = run_simulation(
            simulation_parameters)

        # Roundtrip the results through our JSON encoder to get data the same
        # shape - note that this means that any flaws in the JSON encoder will
        # NOT be revealed by this test.
        expected_simulation_results_json = json.dumps(
            expected_simulation_results_frame,
            cls=DataFrameJSONEncoder)
        expected_simulation_results_dict = json.loads(
            expected_simulation_results_json)

        # First request the results URL
        resp = await cli.post(
            '/simulate',
            data=json.dumps({'name': simulation_name,
                             'parameters': simulation_parameters}))
        assert resp.status == 200
        data = await resp.json()
        # assert resp['result-id'] == 'asdfadsfa'

        # Now request the result
        resp = await cli.get(
            '/simulation/{}'.format(data['result-id']))
        assert resp.status == 200
        data = await resp.json()

        # Do they match?
        assert data['status'] == 'success'
        assert data['name'] == simulation_name
        assert data['params'] == simulation_parameters
        assert data['results'] == expected_simulation_results_dict


async def test_simulate_route_with_malformed_intervention(cli):
    resp = await cli.post(
        '/simulate',
        data=json.dumps(MALFORMED_INTERVENTION_REQUEST))
    assert resp.status == 200
    data = await resp.json()

    resp = await cli.get(
        '/simulation/{}'.format(data['result-id']))
    assert resp.status == 200
    data = await resp.json()
    assert data['status'] == 'error'


async def test_simulate_route_with_unknown_intervention(cli):
    resp = await cli.post(
        '/simulate',
        data=json.dumps(UNKNOWN_INTERVENTION_REQUEST))
    assert resp.status == 200
    data = await resp.json()

    resp = await cli.get(
        '/simulation/{}'.format(data['result-id']))
    assert resp.status == 200
    data = await resp.json()
    assert data['status'] == 'error'
