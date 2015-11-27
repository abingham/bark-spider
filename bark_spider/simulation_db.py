import hashlib
import json


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
