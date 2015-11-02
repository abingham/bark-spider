# Bark Spider

A web interface for Sixty North's software process simulation tools.

## Quickstart

1. Create a virtual environment with Python 3.4:

        $ mkvirtualenv bark-spider --python=python3.4

2. Clone this Git repository:

        $ git clone git@github.com:sixty-north/bark-spider.git

3. Install the dependencies (the simulator and interventions are installed in development mode direct from GitHub):

        $ cd bark-spider/
        $ pip install -r requirements.txt

4. Start the server:

        $ pserve development.ini

5. Visit <http://0.0.0.0:6543> in your browser

6. Run rings around the competition with your new-found insight into
   software processes.


## Testing

To run the JSON API approval tests:

    python -m unittest bark_spider.tests

More tests coming soon...
