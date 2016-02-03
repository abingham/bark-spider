module BarkSpider.Util where

import Effects exposing (Effects)

noFx : model -> (model, Effects a)
noFx model = (model, Effects.none)
