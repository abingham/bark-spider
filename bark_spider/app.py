from aiohttp import web
from bark_spider.intervention import ParseError
from bark_spider.json_util import DataFrameJSONEncoder
from bark_spider.simulation_db import SimulationDatabase
from functools import partial
import json

# TODO: We should probably be attaching this to the request or something,
# right
sim_db = SimulationDatabase()

# async def handle(request):
#     name = request.match_info.get('name', "Anonymous")
#     text = "Hello, " + name
#     return web.Response(text=text)


async def root(request):
    return web.HTTPFound('static/index.html')


async def handle_simulate(request):
    data = await request.json()
    name = data['name']
    params = data['parameters']

    try:
        name_hash, _ = sim_db.add_results(name, params)
    except ParseError as e:
        # Note the dissonance here. The intervention ParseError happens here
        # because of lazy parsing, while you might expect it to happen above.
        return web.HTTPBadRequest(body=str(e))

    return web.json_response({
        'url': request.app.router['simulation'].url(parts={"id": name_hash}),
        'result-id': name_hash,
    })


def handle_simulation(request):
    name_hash = request.match_info['id']

    try:
        name, sim_params, sim_results = sim_db.lookup(name_hash)
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
