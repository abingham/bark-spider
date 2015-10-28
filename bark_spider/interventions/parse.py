import stevedore

_INTERVENTIONS = None

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

    print(_INTERVENTIONS)
    return _INTERVENTIONS


def _parse_intervention(line):
    """Parse a single line of the interventions DSL.

    This find the Intervention plugin associated with the command
    portion of the line. It then ues the plugin to construct the right
    Intervention instance.
    """
    assert line

    (command, time, *args) = line.split()
    command = command.lower()

    try:
        cls = _interventions()[command]
    except KeyError:
        raise ValueError(
            'Unknown command {} while parsing interventions. '
            '(full command={})'.format(
                command, line))

    return cls.make_instance(int(time), *args)


def parse_interventions(stream):
    """Parse the interventions DSL from a text stream.

    Args:
        stream: A file-like object containing the interventions DSL.

    Returns: An iterable of Intervention instances.
    """
    stripped_lines = map(str.strip, stream.readlines())
    non_empty_lines = filter(bool, stripped_lines)
    return map(_parse_intervention, non_empty_lines)
