import json

import pandas


class DataFrameJSONEncoder(json.JSONEncoder):
    @staticmethod
    def string_keys(d):
        "Covert all keys to strings in a dict."
        return {str(k): str(v) for k, v in d.items()}

    def default(self, obj):
        if isinstance(obj, pandas.DataFrame):
            # The DataFrame.to_dict() returns some dicts with integer
            # keys, and the json encoder requires these keys to be
            # strings. Hence the conversion.
            return {
                k: self.string_keys(v)
                for k, v in obj.to_dict().items()
            }
        return json.JSONEncoder.default(self, obj)
