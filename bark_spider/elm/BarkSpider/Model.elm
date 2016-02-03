module BarkSpider.Model where

import BarkSpider.Simulation.Model exposing (createSimulation, Simulation)

type alias ID = Int

type alias Model =
  { simulations : List (ID, Simulation)
  , results : String
  , error_messages : List String
  , next_id : Int
  }

createModel : Model
createModel =
  let
    sim = createSimulation "unnamed"
  in
    { simulations = []
    , results = ""
    , error_messages = []
    , next_id = 0
    }
