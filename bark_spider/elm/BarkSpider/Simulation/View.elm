module BarkSpider.Simulation.View where

import BarkSpider.Simulation.Actions exposing (..)
import BarkSpider.Simulation.Model exposing (..)
import Bootstrap.Html exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String

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

assimilationDelayControls : Signal.Address Action -> Simulation -> List Html
assimilationDelayControls address sim =
  let
    sendSignal = String.toInt >> Result.withDefault 0 >> SetAssimilationDelay >> SetParameter >> Signal.message address
  in
    [ row_
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
    ]

trainingOverheadControls : Signal.Address Action -> Simulation -> List Html
trainingOverheadControls address sim =
  let
    sendSignal = String.toFloat >> Result.withDefault 0 >> SetTrainingOverheadProportion >> SetParameter >> Signal.message address
  in
    [ row_
        [ colSm_ 4 4
            [ label [ class "control-label pull-right"] [text "Training overhead (0-1)" ] ]
        , colSm_ 8 8
            [ input [ class "form-control pull-right"
                    , type' "number"
                    , Html.Attributes.min "0"
                    , Html.Attributes.max "1"
                    , Html.Attributes.step "0.01"
                    , value (toString sim.parameters.training_overhead_proportion)
                    , on "input" targetValue sendSignal
                    ]
                []
            ]
        ]
    ]

interventionsControls : Signal.Address Action -> Simulation -> List Html
interventionsControls address sim =
  let
    sendSignal = SetInterventions >> SetParameter >> Signal.message address
  in
    [ row_
      [ colSm_ 12 12
          [ label [ class "control-label" ] [ text "Interventions" ] ]
      ]
  , row_
      [ colSm_ 12 12
          [ textarea
              [ class "form-control"
              , on "input" targetValue sendSignal
              ]
              []
          ]
      ]
    ]

mainRow : Signal.Address Action -> Simulation -> List Html
mainRow address sim =
  [ row_
      [ div
          [class "input-group"]
          [ hideButton address sim
          , nameControls address sim
          , controlButtons address sim
          ]
      ]
  ]

paramBlock : Signal.Address Action -> Simulation -> List Html
paramBlock address sim =
  let
    html =
      [ assimilationDelayControls address sim
      , trainingOverheadControls address sim
      , interventionsControls address sim
      ]
    result =
      [ div [ class "parameter-set-form" ] (List.concat html) ]
  in
    if sim.hidden then [] else result


view : Signal.Address Action -> Simulation -> Html
view address sim =
  let
    html = List.concat [ mainRow address sim
                       , paramBlock address sim
                       ]
  in
    div [] html
