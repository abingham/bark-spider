module BarkSpider.Simulation where

import Bootstrap.Html exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String

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

hideButton : Signal.Address Action -> Simulation -> Html
hideButton address sim =
  let
    icon = { btnParam | icon = Just (glyphiconChevronDown' "") }
  in
    span
      [ class "input-group-btn" ]
      [ btnDefault' "form-control" icon address (SetHidden (not sim.hidden)) ]

nameControls : Signal.Address Action -> Simulation -> Html
nameControls address sim =
  input [ type' "text"
        , class "form-control"
        , value sim.name
        , on "input" targetValue (Signal.message address <<  SetName)]
    []

controlButtons : Signal.Address Action -> Simulation -> Html
controlButtons address sim =
  let
    included_text = { btnParam | label = Just (if sim.included then "exclude" else "include") }
    delete_text = { btnParam | label = Just "delete" }
  in
    div
      [ class "input-group-btn"]
      [ btnDefault' "" included_text address (SetIncluded (not sim.included))
      , btnDefault' "" delete_text address Delete
      ]

assimilationDelayControls : Signal.Address Action -> Simulation -> Html
assimilationDelayControls address sim =
  let
    sendSignal = String.toInt >> Result.withDefault 0 >> SetAssimilationDelay >> SetParameter >> Signal.message address
  in
    row_
    [ colSm_ 4 4
        [ label [class "control-label pull-right"] [text "Assimilation delay (days)"] ]
    , colSm_ 8 8
        [ input [class "form-control pull-right"
                , type' "number"
                , Html.Attributes.min "0"
                , value (toString sim.parameters.assimilation_delay)
                , on "input" targetValue sendSignal
                ]
            []
        ]
    ]

mainRow : Signal.Address Action -> Simulation -> Html
mainRow address sim =
  row_
  [ div
      [class "input-group"]
      [ hideButton address sim
      , nameControls address sim
      , controlButtons address sim
      ]
  ]

paramBlock : Signal.Address Action -> Simulation -> Html
paramBlock address sim =
  div [ class "parameter-set-form" ]
  [ assimilationDelayControls address sim
  , row_
      [ colSm_ 4 4
          [ label [class "control-label pull-right"] [text "Training overhead (0-1)"] ]
      , colSm_ 8 8
          [ input [class "form-control pull-right", type' "number", Html.Attributes.min "0", Html.Attributes.max "1", value "1"] [] ]
      ]
  , row_
      [ colSm_ 12 12
         [ label [ class "control-label" ] [ text "Interventions" ] ]
      ]
  , row_
      [ colSm_ 12 12
          [ textarea [ class "form-control" ] [] ]
      ]
  ]

view : Signal.Address Action -> Simulation -> Html
view address sim =
  let
    html = [ mainRow address sim ] ++ if sim.hidden then [] else [ paramBlock address sim ]
  in
    div [] html
