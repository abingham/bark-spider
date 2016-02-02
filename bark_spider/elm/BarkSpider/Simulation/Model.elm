module BarkSpider.Simulation.Model where

import Json.Encode exposing (..)

type alias Parameters =
  { assimilation_delay : Int
  , training_overhead_proportion : Float
  , interventions : String
  }

type alias Simulation =
  { name : String
  , included : Bool
  , parameters : Parameters
  , hidden : Bool
  }

createSimulation : String -> Simulation
createSimulation name =
  let
    params = {assimilation_delay = 20, training_overhead_proportion = 0.2, interventions = ""}
  in
    {name = name, included = True, hidden = False, parameters = params}

simulationToJson : Simulation -> Value
simulationToJson sim =
  let
    params = sim.parameters
    params_obj =
      object
        [ ("assimilation_delay", int params.assimilation_delay)
        , ("training_overhead_proportion", float params.training_overhead_proportion)
        , ("interventions", string params.interventions)
        ]
  in
    object
      [ ("name", string sim.name)
      , ("parameters", params_obj)
      ]
