from io import StringIO

from brooks.brooks_law import step
from brooks.simulation import simulate
import pandas

from .schedule import make_schedule


def run_simulation(params):
    """Run a set of simulations using various parameter sets.

    Args:
        params: A dict-like object that will be unpacked as the
            arguments to schedule.make_schedule. In other words, it
            should be key-value pairs defining the state variables for
            the simulations. The "interventions" value should be a
            string containing the intervention DSL to process.

    Returns: A pandas.DataFrame with three columns - step_number,
    elapsed_time, and software_development_rate.

    """
    attributes = ['software_development_rate']

    output_stream = StringIO()
    schedule = make_schedule(**params)

    simulate(schedule, step, output_stream, attributes)
    output_stream.seek(0)

    frame = pandas.read_table(output_stream)

    # This cleans up the null initial rate
    frame['software_development_rate'][0] = 0

    return frame
