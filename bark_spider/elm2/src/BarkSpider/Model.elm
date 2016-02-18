module BarkSpider.Model (..) where

import BarkSpider.Simulation as Sim
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
      Sim.Parameters
      -- Parameters used to calculate the results
  , data :
      SimulationData
      -- The results themselves
  }


{-| Top-level model for the app.
-}
type alias Model =
  { simulations : Dict.Dict ID Sim.Simulation
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
addSimulation : Model -> ID -> Sim.Simulation -> Model
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
