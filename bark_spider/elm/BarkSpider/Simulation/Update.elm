module BarkSpider.Simulation.Update where

import BarkSpider.Simulation.Model exposing (..)
import BarkSpider.Simulation.Actions exposing (..)

updateParameters : ParameterAction -> Parameters -> Parameters
updateParameters action params =
  case action of
    SetAssimilationDelay d ->
      {params | assimilation_delay = d}

    SetTrainingOverheadProportion p ->
      {params | training_overhead_proportion = p}

    SetInterventions i ->
      {params | interventions = i}

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

      SetHidden h ->
        {model | hidden = h}

      SetParameter a ->
        {model | parameters = updateParameters a model.parameters}

      _ -> model
