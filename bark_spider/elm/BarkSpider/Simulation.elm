module BarkSpider.Simulation where

import Bootstrap.Html exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)

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
  | SetHidden Bool
  | SetParameter ParameterAction
  | Delete

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

mainRow : Signal.Address Action -> Simulation -> Html
mainRow address sim =
  let
    icon = { btnParam | icon = Just (glyphiconChevronDown' "") }
    included_text = { btnParam | label = Just (if sim.included then "exclude" else "include") }
    delete_text = { btnParam | label = Just "delete" }
  in
    row_
    [ div [class "input-group"]
        [ span [ class "input-group-btn" ] [ btnDefault' "form-control" icon address (SetHidden (not sim.hidden)) ] -- this toggles visibility of sim details
        , input [ type' "text", class "form-control", value sim.name ] [] -- How do we update sim.name when this value changes?
        , div [ class "input-group-btn"]
            [ btnDefault' "" included_text address (SetIncluded (not sim.included))
            , btnDefault' "" delete_text address Delete
            ]
        ]
    ]

paramBlock : Html
paramBlock =
  text "PARAM BLOCK"

view : Signal.Address Action -> Simulation -> Html
view address sim =
  let
    html = [ mainRow address sim ] ++ if sim.hidden then [] else [ paramBlock ]
  in
    div [] html
