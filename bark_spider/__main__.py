from aiohttp import web
from bark_spider.app import app

web.run_app(app())
