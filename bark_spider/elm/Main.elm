module BarkSpider (..) where

import BarkSpider.App exposing (app)
import Dict
import Effects
import Html
import Task
import UrlParameterParser

import Debug

main : Signal Html.Html
main =
  let
    foo = Debug.log "params" parameters
  in
    app.html

port locationSearch : String

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks

parameters : Dict.Dict String String
parameters =
  case (UrlParameterParser.parseSearchString locationSearch) of
    UrlParameterParser.Error _ -> Dict.empty
    UrlParameterParser.UrlParams dict -> dict

-- TODO: git submodule for urlparam stuff
