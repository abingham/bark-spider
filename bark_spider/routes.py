def configure_routes(config):
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_static_view('elm', 'elm')
    config.add_route('home', '/')
    config.add_route('simulate', '/simulate')
    config.add_route('simulation', '/simulation/{id}')
    config.scan()
