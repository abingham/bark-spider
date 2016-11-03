# Bark Spider

A web interface for Sixty North's software process simulation tools.

## Quickstart

The first thing you need to do is clone this repository:

```shell
git clone git@github.com:sixty-north/bark-spider
cd bark-spider
```

Now set up the rest of the environment:

1. Create a virtual environment with Python 3.5:

```shell
mkvirtualenv bark-spider --python=python3.5
```

2. Install the Python dependencies (the simulator and interventions are
   installed in development mode direct from GitHub):

```shell
pip install -r requirements.txt
```

3. Make sure you have a few non-Python dependencies:

  - [elm](http://elm-lang.org/install): Version 0.17. Use the correct installer for your system, or try `npm install -g elm`.

4. Build the Elm elements of the system:

```shell
pushd bark_spider/elm/
elm-make Main.elm --yes --output=bark_spider.js
popd
```

5. Install the bark spider server

```shell
python setup.py install
```

6. Start the server:

```shell
python -m bark_spider.app
```


7. Visit <http://0.0.0.0:8080> in your browser.

8. Run rings around the competition with your new-found insight into
   software processes.

## Testing

**NB: This is out of date right now. Sorry.**

To run the JSON API approval tests:

    python -m unittest bark_spider.tests

More tests coming soon...
