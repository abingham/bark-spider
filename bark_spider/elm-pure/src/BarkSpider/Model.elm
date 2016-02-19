module BarkSpider.Model (..) where

import BarkSpider.Simulation exposing (Simulation)
import BarkSpider.Comms exposing (SimulationResults)
import Dict


type alias ID =
  Int

{-| Top-level model for the app.
-}
type alias Model =
  { simulations : Dict.Dict ID Simulation
  , results : List SimulationResults
  , error_messages : List String
  }


{-|
-}
createModel : Model
createModel =
  { simulations = Dict.empty
  , results = []
  , error_messages = []
  }


{-|
-}
addSimulation : Model -> ID -> Simulation -> Model
addSimulation model id sim =
  { model
    | simulations = Dict.insert id sim model.simulations
  }


{-|
-}
removeSimulation : Model -> ID -> Model
removeSimulation model id =
  { model
    | simulations = Dict.remove id model.simulations
  }


{-|
-}
clearSimulationResults : Model -> Model
clearSimulationResults model =
  { model
    | results = []
  }
