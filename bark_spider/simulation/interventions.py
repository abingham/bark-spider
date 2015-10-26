"""Parsing and support classes for the interventions DSL.
"""


class Intervention:
    def __init__(self, time):
        self._time = time

    @property
    def time(self):
        "The elapsed time at which the intervention takes place."
        return self._time

    def apply(self, state):
        raise NotImplementedError('_apply() not implemented')


class AddDevelopers(Intervention):
    def __init__(self, time, num_developers):
        super().__init__(time)
        self._num_developers = num_developers

    @property
    def num_developers(self):
        "The number of developers to add."
        return self._num_developers

    def apply(self, state):
        state.num_new_personnel += self.num_developers
        return state


def _parse_intervention(line):
    (command, time, *args) = line.split()
    command = command.lower()

    if command == 'add':
        return AddDevelopers(int(time), int(args[0]))

    raise ValueError(
        'Unknown command {} while parsing interventions. '
        '(full command={})'.format(
            command, line))


def parse_interventions(stream):
    """Parse the interventions DSL from a text stream.

    Args:
        stream: A file-like object containing the interventions DSL.
    """
    return (_parse_intervention(line)
            for line in map(str.strip,
                            stream.readlines())
            if line)
