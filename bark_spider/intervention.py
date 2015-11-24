"""Base class, plugin, and parsing support for interventions.
"""

import stevedore

_INTERVENTIONS = None


class ParseError(Exception):
    pass


def _interventions():
    """Get the dict mapping tag names to Intervention subclasses.

    This loads the plugins if necessary. This function caches its
    result, so it's efficient to call this as many times as you want.
    """
    global _INTERVENTIONS
    if _INTERVENTIONS is None:
        _INTERVENTIONS = {
            ext.plugin.tag(): ext.plugin
            for ext in stevedore.ExtensionManager(
                    namespace='bark_spider.interventions')
        }

    assert _INTERVENTIONS is not None

    return _INTERVENTIONS


def _parse_intervention(line):
    """Parse a single line of the interventions DSL.

    This find the Intervention plugin associated with the command
    portion of the line. It then ues the plugin to construct the right
    Intervention instance.

    Raises:
        ParseError: Unknown or malformed intervention encountered.
    """
    assert line

    try:
        (command, time, *args) = line.split()
    except ValueError:
        raise ParseError(
            'Interventions must follow the form "<name> <time> \
            [args . . .]" (value={})'.format(
                line))

    command = command.lower()

    try:
        cls = _interventions()[command]
    except KeyError:
        raise ParseError(
            'Unknown command "{}" while parsing interventions. '
            '(full command={})'.format(
                command, line))

    try:
        return cls.make_instance(int(time), *args)
    except Exception as e:
        raise ParseError(
            'Invalid command while parsing intervention: {}'.format(
                line)) from e


def parse_interventions(stream):
    """Parse the interventions DSL from a text stream.

    Args:
        stream: A file-like object containing the interventions DSL.

    Returns: An iterable of Intervention instances.

    Raises:
        ValueError: If there is an error parsing the stream.
    """
    stripped_lines = map(str.strip, stream.readlines())
    non_empty_lines = filter(bool, stripped_lines)
    return map(_parse_intervention, non_empty_lines)


class Intervention:
    def __init__(self, time):
        self._time = time

    @classmethod
    def tag(cls):
        raise NotImplementedError('tag not implemented')

    @property
    def time(self):
        "The elapsed time at which the intervention takes place."
        return self._time

    def apply(self, state):
        """Apply intervention to `state`.

        This function should make whatever changes it needs to the
        `state`, returning the a `State` object. The returned state
        can be a new object or the modified original.

        """
        raise NotImplementedError('apply() not implemented')

    @classmethod
    def make_instance(self, time, *args):
        """Return a new Intervention instance of the appropriate type.

        Args:
            time: elapsed time at which intervention occurs (int)
            args: any remaining aguments to the command (iterable of str)
        """
        raise NotImplementedError('apply() not implemented')
