from pyramid.config import Configurator

from .routes import configure_routes
from .simulation_db import SimulationDatabase

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.include('pyramid_chameleon')
    configure_routes(config)

    sim_db = SimulationDatabase()

    config.add_request_method(
        lambda request: sim_db, 'db', reify=True)

    return config.make_wsgi_app()
