module BarkSpider.App (..) where

import BarkSpider.Model exposing (createModel, Model)
import BarkSpider.Util exposing (noFx)
import BarkSpider.Update exposing (update)
import BarkSpider.View exposing (view)
import StartApp


app : StartApp.App Model
app =
  StartApp.start
    { init = noFx (createModel)
    , view = view
    , update = update
    , inputs = []
    }
