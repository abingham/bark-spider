module BarkSpider (..) where

import BarkSpider.App exposing (app)
import Dict
import Effects
import Html
import Task
import UrlParameterParser


main : Signal Html.Html
main =
  app.html


{-| Standard port for letting tasks interact with the native world.
-}
port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks


{-| The URL parameter dict provided when the page is invoked.
-}
parameters : Dict.Dict String String
parameters =
  case (UrlParameterParser.parseSearchString locationSearch) of
    UrlParameterParser.Error _ ->
      Dict.empty

    UrlParameterParser.UrlParams dict ->
      dict


{-| Port for receiving any URL parameters the user provided.
 -}
port locationSearch : String
