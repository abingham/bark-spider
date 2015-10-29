"""Tests for the bark-spider JSON API.

These are essentially approval tests. We've captured some input-output
pairs and deemed those "correct". If there are deviations in the
output (i.e. test failures) you should investigate them and either:

* fix the code that causes the tests to fail, or
* update the tests to reflect the new notion of correct

In other words, these are tests to detect that we've noticed that our
JSON data has changed.

"""

import unittest

from pyramid import testing

TEST_DATA = [
    ({'name': 'test params',
      'parameters': {
          'assimilation_delay': 20,
          'training_overhead_proportion': 0.25,
          'interventions': '',
          'num_function_points_requirements': 10
      }
    },
     {"step_number": {
         "1": "1", "4": "4", "5": "5", "10": "10", "6": "6", "2": "2",
         "8": "8", "7": "7", "0": "0", "9": "9", "3": "3"},
       "software_development_rate": {
           "1": "0.8065923869047285", "4": "0.9495863290658887",
           "5": "0.9925659718916292", "10": "0", "6": "1.0333966325760826",
           "2": "0.8567217268385271", "8": "1.109035431494033",
           "7": "1.0721857602263134", "0": "0", "9": "1.1440426191983664",
           "3": "0.9043445997756356"},
       "elapsed_time": {
           "1": "1", "4": "4", "5": "5", "10": "10", "6": "6",
           "2": "2", "8": "8", "7": "7", "0": "0", "9": "9",
           "3": "3"}}),

    ({'name': 'test params1',
      'parameters': {
          'assimilation_delay': 20,
          'training_overhead_proportion': 0.25,
          'interventions': '',
          'num_function_points_requirements': 5
      },
    },
    {'step_number': {
        '5': '5', '1': '1', '2': '2', '4': '4', '3': '3',
        '6': '6', '0': '0'},
     'elapsed_time': {
         '5': '5', '1': '1', '2': '2', '4': '4', '3': '3',
         '6': '6', '0': '0'},
     'software_development_rate': {
         '5': '0.9925659718916292', '1': '0.8065923869047285',
         '2': '0.8567217268385271', '4': '0.9495863290658887',
         '3': '0.9043445997756356', '6': '0', '0': '0'}}),
    ]


class SimulateRouteTests(unittest.TestCase):
    def setUp(self):
        self.config = testing.setUp()

        # We need this so that route_url() will work in simulate_route()
        self.config.add_route('simulation', '/simulation/{id}')

    def tearDown(self):
        testing.tearDown()

    def test_simulate_route(self):
        from .views import simulate_route, simulation_route

        for req_data, expected in TEST_DATA:
            # First request the results URL
            request = testing.DummyRequest()
            request.json_body = req_data
            response = simulate_route(request)
            result_id = response['result-id']

            # now request the result
            request = testing.DummyRequest()
            request.matchdict['id'] = result_id
            response = simulation_route(request)

            self.assertEqual(
                response.json_body['name'],
                req_data['name'])

            self.assertEqual(
                response.json_body['parameters'],
                req_data['parameters'])

            self.assertEqual(
                response.json_body['results'],
                expected)

            self.assertEqual(
                response.status_code, 200)

            self.assertEqual(
                response.content_type, 'application/json')
