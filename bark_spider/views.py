from io import BytesIO, StringIO

import pandas
from pyramid.response import Response
from pyramid.view import view_config

from brooks.brooks_law import step
import brooks.communication
from brooks.simulation import simulate
from brooks.state import State
from plotter.plot_timeseries import plot_timeseries


class Schedule:
    def __init__(self, elapsed, added):
        self._elapsed = elapsed
        self._added = added

    def initial(self):
        """Configure the initial model state."""
        return State(
            step_duration_days=1,
            num_function_points_requirements=500,
            num_function_points_developed=0,
            num_new_personnel=20,
            num_experienced_personnel=0,
            personnel_allocation_rate=0,
            personnel_assimilation_rate=0,
            assimilation_delay_days=20,
            nominal_productivity=0.1,
            new_productivity_weight=0.8,
            experienced_productivity_weight=1.2,
            training_overhead_proportion=0.25,
            communication_overhead_function=brooks.communication.gompertz_overhead_proportion,
            software_development_rate=None,
            cumulative_person_days=0,
        )

    def intervene(self, step_number, elapsed_time, state):
        """Intervene in the current step before the main simulation step is
        executed.
        """
        if elapsed_time == self._elapsed:
            state.num_new_personnel += self._added
        return state

    def is_complete(self, step_number, elapsed_time_seconds, state):
        """Determine whether the simulation should end."""
        return state.num_function_points_developed >= state.num_function_points_requirements

    def complete(self, step_number, elapsed_time_seconds, state):
        """Finalise the simulation state for the last recorded step."""
        state.software_development_rate = 0
        return state


@view_config(route_name='home', renderer='templates/main_plot.pt')
def main_plot(request):
    return {'project': 'bark_spider'}


@view_config(route_name='simulate',
             request_method='POST')
def simulate_route(request):
    attributes = ['software_development_rate']
    elapsed = request.json_body['elapsed']
    added = request.json_body['added']

    output_stream = StringIO()

    simulate(Schedule(elapsed, added), step, output_stream, attributes)

    output_stream.seek(0)
    # TODO: The first entry in the dataframe has None for development rate. What does plotter do?

    print(output_stream.read())
    output_stream.seek(0)

    frame = pandas.read_table(output_stream)
    return Response(body=frame.to_json(), content_type='text/json')
