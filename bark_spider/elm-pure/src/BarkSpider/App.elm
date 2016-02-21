module BarkSpider.App (app) where

import BarkSpider.Util exposing (noFx)
import BarkSpider.View exposing (view, update, defaultViewModel, ViewModel)
import StartApp

app : StartApp.App ViewModel
app =
  StartApp.start
    { init = noFx defaultViewModel
    , view = view
    , update = update
    , inputs = []
    }
