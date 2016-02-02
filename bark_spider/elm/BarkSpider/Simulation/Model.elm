module BarkSpider.Simulation.Model where

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
