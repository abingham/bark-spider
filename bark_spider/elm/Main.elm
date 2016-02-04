module BarkSpider (..) where

import BarkSpider.App exposing (app)
import Effects
import Html
import Task


main : Signal Html.Html
main =
  app.html


port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
