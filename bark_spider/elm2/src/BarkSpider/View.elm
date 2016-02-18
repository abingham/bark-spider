module BarkSpider.View where

import Dict
import BarkSpider.Model as Model

type alias ViewModel =
  { model : Model.Model
  , hidden : Dict Model.ID Bool
  }
