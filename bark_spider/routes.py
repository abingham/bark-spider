def configure_routes(config):
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_static_view(name='elm', path='elm')
    config.add_route('root', '/')
    config.add_route('simulate', '/simulate')
    config.add_route('simulation', '/simulation/{id}')
    config.scan()
