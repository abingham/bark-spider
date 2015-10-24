from pyramid.config import Configurator

from .routes import configure_routes


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.include('pyramid_chameleon')
    configure_routes(config)
    return config.make_wsgi_app()
