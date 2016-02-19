module BarkSpider.View (..) where

import Html exposing (Html, node, href)
import Html.Attributes exposing (rel)
import Dict
import BarkSpider.Model as Model
import BarkSpider.Simulation as Sim


type alias ViewModel =
  { model : Model.Model
  , hidden : Dict Model.ID Bool
  }

type Action
  = AddSimulation Sim.Simulation
  | DeleteSimulation Model.ID
  | SetHidden Model.ID Bool
  | SetAssimilationDelay Model.ID
  | SetTrainingOverheadProportion Model.ID
  | SetInterventions Model.ID
  | SetName Model.ID
  | SetIncluded Model.ID
  | RunSimulation

-- Simulation view
hideButton : Signal.Address Action -> Simulation -> Html
hideButton address sim =
  let
    icon = if sim.hidden then glyphiconChevronRight' else glyphiconChevronDown'
    params = { btnParam | icon = Just (icon "") }
  in
    span
      [ class "input-group-btn" ]
      [ btnDefault' "form-control" params address (SetHidden (not sim.hidden)) ]

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
              [text sim.parameters.interventions]
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


simulationView : Signal.Address Action -> Simulation -> Html
simulationView address sim =
  let
    html = List.concat [ mainRow address sim
                       , paramBlock address sim
                       ]
  in
    div [] html


-- Model view

stylesheet : String -> Html
stylesheet url =
  node "link" [ rel "stylesheet", href url ] []


script : String -> Html
script url =
  node "script" [ src url ] []


simView : Signal.Address Action -> ( ID, Simulation ) -> Html
simView address ( id, sim ) =
  SimView.view (Signal.forwardTo address (Modify id)) sim


resultToSeries : Model.SimulationResults -> (Float -> Color) -> Series
resultToSeries result color =
  ( result.name
  , defStyle color
  , Dict.values result.data.software_development_rate
  )


resultsToChart : List Model.SimulationResults -> Html
resultsToChart results =
  let
    res1 =
      List.head results
  in
    case res1 of
      Just res ->
        let
          config =
            ( Dict.values res.data.elapsed_time |> List.map toString
            , List.map2 resultToSeries results distinctColors
            )

          options =
            { defaultOptions
              | animation = False
              , pointDot = False
            }
        in
          chart 1000 1000 config options
            |> fromElement

      -- TODO: Insert legend. We need to add support for legends to the chartjs bindings.

      Nothing ->
        div [] []


view : Signal.Address Action -> ViewModel -> Html
view address viewModel =
  containerFluid_
    [ stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"
    , stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css"
    , script "https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"
    , script "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"
    , row_
        [ colMd_
            4
            4
            4
            ([ h1 [] [ text "Simulation parameters" ]
             , row_
                [ colMd_
                    12
                    12
                    12
                    [ btnDefault' "" { btnParam | label = Just "Add parameter set" } address (AddSimulation (Sim.createSimulation "unnamed"))
                    , btnDefault' "pull-right btn-primary" { btnParam | label = Just "Run simulation" } address RunSimulation
                    ]
                ]
             , hr [] []
             ]
              ++ List.map (simView address) viewModel.model.simulations
            )
        , colMd_
            8
            8
            8
            [ Html.Lazy.lazy resultsToChart viewModel.model.results
            , text (String.concat viewModel.model.error_messages)
            ]
        ]
    ]
