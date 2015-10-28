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


class AddDevelopers(Intervention):
    def __init__(self, time, num_developers):
        super().__init__(time)
        self._num_developers = num_developers

    @classmethod
    def tag(cls):
        return "add"

    @property
    def num_developers(self):
        "The number of developers to add."
        return self._num_developers

    @classmethod
    def make_instance(cls, time, num_devs):
        return AddDevelopers(time, int(num_devs))

    def apply(self, state):
        state.num_new_personnel += self.num_developers
        return state
