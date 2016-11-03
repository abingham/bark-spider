import asyncio
from bark_spider.intervention import parse_interventions
from bark_spider.simulation.simulation import run_simulation
import hashlib
from io import StringIO
import json


class SimulationDatabase:
    def __init__(self):
        self._names = {}  # hash(name + params) -> (name, hash(params))
        self._results = {}  # hash(params) -> (params, results)

    def add_results(self, name, params):
        # We have to distinguish between a) *index params* which are used to
        # calculate the index in the database and b) *run params* which contain
        # parsed interventions (and are hence not json-serializable and
        # therefor not suitable for indexing).
        run_params = params.copy()
        run_params['interventions'] = parse_interventions(
            StringIO(run_params['interventions']))
        name_hash, params_hash = self._hash_request(name, params)
        self._names[name_hash] = (name, params_hash)

        async def run():
            # TODO: Should run_simulation be async? Doesn't seem so.
            results = run_simulation(run_params)
            self._results[params_hash] = (params, results)

        if params_hash not in self._results:
            asyncio.ensure_future(run())

        return (name_hash, params_hash)

    def lookup(self, name_hash):
        """Lookup the simulation results associated with name_hash.

        Returns:
            A 3-tuple of (name, params, results).

        Raises:
            KeyError: If there are no results associated with name_hash.
        """
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
