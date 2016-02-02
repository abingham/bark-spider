This is an experimental version of bark-spider's web UI implemented using [elm](elm-lang.org).

Elm is a functional, statically-typed language, similar in flavor to F# and
Haskell. It's main purpose is for writing functional-reactive web pages, and as
such it compiles to a mix HTML, JavaScript, and CSS.

The goal of this experiment is to make an elm version of the bark-spider UI that
is feature-comparable with the Angular version. The purpose is to get feel for
elm in a real project, and to see...for lack of a better term...if it's worth
the effort.

## Quickstart

1. [Install elm](http://elm-lang.org/install).

2. `cd` to the directory containing this file.

3. Build the HTML and JavaScript from the elm source:

```
elm-make --yes BarkSpider.elm
```

This will install a bunch of dependencies and output an `index.html` file. This
will be served through pyramid at the `/elm` endpoint.

4. Run the pyramid server as normal:

```
cd ../..
pserve development.ini
```
