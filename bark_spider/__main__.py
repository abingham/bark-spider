from aiohttp import web
from bark_spider.app import make_app

web.run_app(make_app())
