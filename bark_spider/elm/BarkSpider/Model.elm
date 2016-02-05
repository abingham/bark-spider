module BarkSpider.Model (..) where

import BarkSpider.Simulation.Model exposing (createSimulation, Parameters, Simulation)
import Dict


type alias ID =
  Int


{-| The "data" payload of a simulation
-}
type alias SimulationData =
  { software_development_rate : Dict.Dict Int Float
  , elapsed_time : Dict.Dict Int Int
  }


{-| The results for a single simulation, including metadata, parameters, and data.
-}
type alias SimulationResults =
  { name :
      String
      -- Name assigned to the results
  , parameters :
      Parameters
      -- Parameters used to calculate the results
  , data :
      SimulationData
      -- The results themselves
  }


{-| Top-level model for the app.
-}
type alias Model =
  { simulations : List ( ID, Simulation )
  , results : List SimulationResults
  , error_messages : List String
  , next_id : Int
  }


createModel : Model
createModel =
  let
    sim =
      createSimulation "unnamed"
  in
    { simulations = []
    , results = []
    , error_messages = []
    , next_id = 0
    }
