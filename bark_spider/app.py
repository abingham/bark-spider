from aiohttp import web
from aiohttp.file_sender import FileSender
from bark_spider.intervention import ParseError
from bark_spider.json_util import DataFrameJSONEncoder
from bark_spider.simulation_db import SimulationDatabase
from functools import partial
import json
from pathlib import Path


async def root(request):
    fs = FileSender()
    path = Path('bark_spider/static/index.html')
    result = await fs.send(request, path)
    return result


async def handle_simulate(request):
    data = await request.json()
    name = data['name']
    params = data['parameters']

    try:
        name_hash, _ = request.app['simdb'].add_results(name, params)
    except ParseError as e:
        return web.HTTPBadRequest(body=str(e))

    return web.json_response({
        'url': request.app.router['simulation'].url(parts={"id": name_hash}),
        'result-id': name_hash,
    })


async def handle_simulation(request):
    name_hash = request.match_info['id']

    try:
        name, sim_params, sim_results = request.app['simdb'].lookup(name_hash)
    except KeyError as e:
        raise web.HTTPNotFound(body="No such simulation id {}".format(e))

    results = {
        'name': name,
        'parameters': sim_params,
        'results': sim_results
    }

    return web.json_response(
        results,
        dumps=partial(json.dumps, cls=DataFrameJSONEncoder))


app = web.Application()
app['simdb'] = SimulationDatabase()
# TODO: What's the correct way to set the path to static and elm? Through a config file? How does the pyramid version do it?
app.router.add_static('/static/',
                      path='bark_spider/static',
                      name='static')
app.router.add_static('/elm/',
                      name='elm',
                      path='bark_spider/elm',)
app.router.add_get('/',
                   root,
                   name='root')
app.router.add_post('/simulate',
                    handle_simulate,
                    name='simulate')
app.router.add_get('/simulation/{id}',
                   handle_simulation,
                   name='simulation')

web.run_app(app)
