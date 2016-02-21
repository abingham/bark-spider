module BarkSpider.View (..) where

import BarkSpider.Comms as Comms
import BarkSpider.Model as Model
import BarkSpider.Simulation exposing (Simulation, createSimulation)
import BarkSpider.Util exposing (distinctColors, noFx)
import Bootstrap.Html exposing (glyphiconChevronRight', glyphiconChevronDown', btnParam, btnDefault', row_, colSm_, containerFluid_, colMd_)
import Chartjs.Line exposing (defStyle, defaultOptions, chart)
import Color
import Dict
import Effects
import Html exposing (Html, node, span, input, div, label, text, textarea, fromElement, h1, hr)
import Html.Attributes exposing (rel, class, type', value, href, src)
import Html.Events exposing (on, targetValue)
import Html.Lazy
import String


type alias SimViewParams =
  { hidden : Bool
  }


defaultSimViewParams : SimViewParams
defaultSimViewParams =
  { hidden = False }


type alias ViewModel =
  { model : Model.Model
  , sim_view_params : Dict.Dict Model.ID SimViewParams
  , next_id : Model.ID
  }


defaultViewModel : ViewModel
defaultViewModel =
  { model = Model.createModel
  , sim_view_params = Dict.empty
  , next_id = 0
  }


type SimulationAction
  = Delete
  | SetHidden Bool
  | SetAssimilationDelay Int
  | SetTrainingOverheadProportion Float
  | SetInterventions String
  | SetName String
  | SetIncluded Bool


type Action
  = AddSimulation Simulation
  | ModifySimulation Model.ID SimulationAction
  | RunSimulation


update : Action -> ViewModel -> ( ViewModel, Effects.Effects Action )
update action viewModel =
  case action of
    AddSimulation sim ->
      let
        id =
          viewModel.next_id

        model =
          Model.addSimulation viewModel.model id sim
      in
        { viewModel
          | model = model
          , next_id = id + 1
        }
          |> noFx

    _ ->
      noFx viewModel



-- Simulation view


hideButton : Signal.Address SimulationAction -> Simulation -> SimViewParams -> Html
hideButton address sim viewParams =
  let
    icon =
      if viewParams.hidden then
        glyphiconChevronRight'
      else
        glyphiconChevronDown'

    params =
      { btnParam | icon = Just (icon "") }
  in
    span
      [ class "input-group-btn" ]
      [ btnDefault' "form-control" params address (SetHidden (not viewParams.hidden)) ]


nameControls : Signal.Address SimulationAction -> Simulation -> Html
nameControls address sim =
  input
    [ type' "text"
    , class "form-control"
    , value sim.name
    , on "input" targetValue (Signal.message address << SetName)
    ]
    []


controlButtons : Signal.Address SimulationAction -> Simulation -> Html
controlButtons address sim =
  let
    included_text =
      { btnParam
        | label =
            Just
              (if sim.included then
                "exclude"
               else
                "include"
              )
      }

    delete_text =
      { btnParam | label = Just "delete" }
  in
    div
      [ class "input-group-btn" ]
      [ btnDefault' "" included_text address (SetIncluded (not sim.included))
      , btnDefault' "" delete_text address Delete
      ]


assimilationDelayControls : Signal.Address SimulationAction -> Simulation -> List Html
assimilationDelayControls address sim =
  let
    sendSignal =
      String.toInt >> Result.withDefault 0 >> SetAssimilationDelay >> Signal.message address
  in
    [ row_
        [ colSm_
            4
            4
            [ label [ class "control-label pull-right" ] [ text "Assimilation delay (days)" ] ]
        , colSm_
            8
            8
            [ input
                [ class "form-control pull-right"
                , type' "number"
                , Html.Attributes.min "0"
                , value (toString sim.parameters.assimilation_delay)
                , on "input" targetValue sendSignal
                ]
                []
            ]
        ]
    ]


trainingOverheadControls : Signal.Address SimulationAction -> Simulation -> List Html
trainingOverheadControls address sim =
  let
    sendSignal =
      String.toFloat >> Result.withDefault 0 >> SetTrainingOverheadProportion >> Signal.message address
  in
    [ row_
        [ colSm_
            4
            4
            [ label [ class "control-label pull-right" ] [ text "Training overhead (0-1)" ] ]
        , colSm_
            8
            8
            [ input
                [ class "form-control pull-right"
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


interventionsControls : Signal.Address SimulationAction -> Simulation -> List Html
interventionsControls address sim =
  let
    sendSignal =
      SetInterventions >> Signal.message address
  in
    [ row_
        [ colSm_
            12
            12
            [ label [ class "control-label" ] [ text "Interventions" ] ]
        ]
    , row_
        [ colSm_
            12
            12
            [ textarea
                [ class "form-control"
                , on "input" targetValue sendSignal
                ]
                [ text sim.parameters.interventions ]
            ]
        ]
    ]


mainRow : Signal.Address SimulationAction -> Simulation -> SimViewParams -> List Html
mainRow address sim viewParams =
  [ row_
      [ div
          [ class "input-group" ]
          [ hideButton address sim viewParams
          , nameControls address sim
          , controlButtons address sim
          ]
      ]
  ]


paramBlock : Signal.Address SimulationAction -> Simulation -> SimViewParams -> List Html
paramBlock address sim viewParams =
  let
    html =
      [ assimilationDelayControls address sim
      , trainingOverheadControls address sim
      , interventionsControls address sim
      ]

    result =
      [ div [ class "parameter-set-form" ] (List.concat html) ]
  in
    if viewParams.hidden then
      []
    else
      result


simulationView : Signal.Address SimulationAction -> Simulation -> SimViewParams -> Html
simulationView address sim viewParams =
  let
    html =
      List.concat
        [ mainRow address sim viewParams
        , paramBlock address sim viewParams
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


simView : Signal.Address Action -> Model.ID -> Simulation -> SimViewParams -> Html
simView address id sim viewParams =
  simulationView (Signal.forwardTo address (ModifySimulation id)) sim viewParams


resultToSeries : Comms.SimulationResults -> (Float -> Color.Color) -> Chartjs.Line.Series
resultToSeries result color =
  ( result.name
  , defStyle color
  , Dict.values result.data.software_development_rate
  )


resultsToChart : List Comms.SimulationResults -> Html
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


viewParamSets : ViewModel -> List ( Model.ID, Simulation, SimViewParams )
viewParamSets viewModel =
  let
    getSimViewParams id =
      Dict.get id viewModel.sim_view_params |> Maybe.withDefault defaultSimViewParams
  in
    List.map
      (\( id, sim ) -> ( id, sim, getSimViewParams id ))
      (Dict.toList viewModel.model.simulations)


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
                    [ btnDefault' "" { btnParam | label = Just "Add parameter set" } address (AddSimulation (createSimulation "unnamed"))
                    , btnDefault' "pull-right btn-primary" { btnParam | label = Just "Run simulation" } address RunSimulation
                    ]
                ]
             , hr [] []
             ]
              ++ List.map (\( id, sim, svp ) -> simView address id sim svp) (viewParamSets viewModel)
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
