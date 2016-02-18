module BarkSpider.Simulation where

import Json.Encode exposing (..)

-- model

type alias Parameters =
  { assimilation_delay : Int
  , training_overhead_proportion : Float
  , interventions : String
  }

type alias Simulation =
  { name : String
  , included : Bool
  , parameters : Parameters
  -- , hidden : Bool -- This is a view-model thing.
  }

createSimulation : String -> Simulation
createSimulation name =
  let
    params = {assimilation_delay = 20, training_overhead_proportion = 0.2, interventions = ""}
  in
    {name = name, included = True, parameters = params}

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

type ParameterAction
  = SetAssimilationDelay Int
  | SetTrainingOverheadProportion Float
  | SetInterventions String

updateParameters : ParameterAction -> Parameters -> Parameters
updateParameters action params =
  case action of
    SetAssimilationDelay d ->
      {params | assimilation_delay = d}

    SetTrainingOverheadProportion p ->
      {params | training_overhead_proportion = p}

    SetInterventions i ->
      {params | interventions = i}

type Action
  = SetName String
  | SetIncluded Bool
  | SetParameter ParameterAction

update : Action -> Simulation -> Simulation
update action model =
  let
    parameters = model.parameters
  in
    case action of
      SetName n ->
        {model | name = n}

      SetIncluded i ->
        {model | included = i}

      SetParameter a ->
        {model | parameters = updateParameters a model.parameters}
