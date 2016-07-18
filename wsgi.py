"""Run bark-spider using waitress.
"""

import bark_spider.app
from waitress import serve

serve(bark_spider.app.make_app(), listen="*:8080")
