module BarkSpider.App (app) where

import BarkSpider.Model exposing (createModel, Model)
import BarkSpider.Util exposing (noFx)
import BarkSpider.View exposing (view, update)
import StartApp

app : StartApp.App Model
app =
  StartApp.start
    { init = noFx createModel
    , view = view
    , update = update
    , inputs = []
    }
