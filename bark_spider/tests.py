"""Tests for the bark-spider JSON API.

These are essentially approval tests.

* fix the code that causes the tests to fail, or
* update the tests to reflect the new notion of correct

In other words, these are tests to detect that we've noticed that our
JSON data has changed.

"""
import json
import unittest
from pyramid import testing
from pyramid.httpexceptions import HTTPBadRequest

from bark_spider.json_util import DataFrameJSONEncoder
from bark_spider.simulation.simulation import run_simulation
from bark_spider.simulation_db import SimulationDatabase

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


class SimulateRouteTests(unittest.TestCase):
    def setUp(self):
        self.config = testing.setUp()

        # We need this so that route_url() will work in simulate_route()
        self.config.add_route('simulation', '/simulation/{id}')

        self._db = SimulationDatabase()

    def tearDown(self):
        testing.tearDown()

    def make_request(self):
        req = testing.DummyRequest()
        req.db = self._db
        return req

    def test_simulate_route(self):
        self.maxDiff = None

        from bark_spider.views import simulate_route, simulation_route

        for req_data in TEST_DATA:
            # Unpack the initial values
            simulation_name = req_data['name']
            simulation_paramaters = req_data['parameters']

            # Determine the expected results by calling the simulator directly
            expected_simulation_results_frame = run_simulation(simulation_paramaters)

            # Roundtrip the results through our JSON encoder to get data the same shape
            # - note that this means that any flaws in the JSON encoder will NOT be
            # revealed by this test.
            expected_simulation_results_json = json.dumps(
                expected_simulation_results_frame,
                cls=DataFrameJSONEncoder)
            expected_simulation_results_dict = json.loads(expected_simulation_results_json)

            # First request the results URL
            request = self.make_request()
            request.json_body = req_data
            response = simulate_route(request)
            result_id = response['result-id']
            self.assertNotIn('error', response)

            # Now request the result
            request = self.make_request()
            request.matchdict['id'] = result_id
            response = simulation_route(request)

            # Do they match?
            self.assertEqual(
                response.json_body['name'],
                simulation_name)

            self.assertEqual(
                response.json_body['parameters'],
                simulation_paramaters)

            self.assertEqual(
                response.json_body['results'],
                expected_simulation_results_dict)

            self.assertEqual(
                response.status_code, 200)

            self.assertEqual(
                response.content_type, 'application/json')

    def test_simulate_route_with_malformed_intervention(self):
        from bark_spider.views import simulate_route

        request = self.make_request()
        request.json_body = MALFORMED_INTERVENTION_REQUEST
        with self.assertRaises(HTTPBadRequest):
            simulate_route(request)

    def test_simulate_route_with_unknown_intervention(self):
        from bark_spider.views import simulate_route

        request = self.make_request()
        request.json_body = UNKNOWN_INTERVENTION_REQUEST
        with self.assertRaises(HTTPBadRequest):
            simulate_route(request)
