module BarkSpider.Simulation (..) where

import Json.Encode exposing (int, float, object, string, Value)
import Bootstrap.Html exposing (btnDefault', btnParam, colSm_, glyphiconChevronDown', glyphiconChevronRight', row_)
import Html exposing (div, Html, input, label, span, text, textarea)
import Html.Attributes exposing (class, type', value)
import Html.Events exposing (on, targetValue)
import String

-- model stuff


{-| Low-level simulation parameters
-}
type alias Parameters =
  { assimilation_delay : Int
  , training_overhead_proportion : Float
  , interventions : String
  }


{-| High-/UI-level simulation parameters
-}
type alias Simulation =
  { name : String
  , included : Bool
  , parameters : Parameters
  , hidden : Bool
  }


{-| Create a new simulation names NAME
-}
createSimulation : String -> Simulation
createSimulation name =
  let
    params =
      { assimilation_delay = 20, training_overhead_proportion = 0.2, interventions = "" }
  in
    { name = name, included = True, hidden = False, parameters = params }


{-| Convert a simulation to a JSON value.
-}
simulationToJson : Simulation -> Value
simulationToJson sim =
  let
    params =
      sim.parameters

    params_obj =
      object
        [ ( "assimilation_delay", int params.assimilation_delay )
        , ( "training_overhead_proportion", float params.training_overhead_proportion )
        , ( "interventions", string params.interventions )
        ]
  in
    object
      [ ( "name", string sim.name )
      , ( "parameters", params_obj )
      ]



-- Update stuff


{-| Actions for modifying low-level parameters
-}
type ParameterAction
  = SetAssimilationDelay Int
  | SetTrainingOverheadProportion Float
  | SetInterventions String


{-| Actions for modifying high-level parameters
-}
type Action
  = SetName String
  | SetIncluded Bool
  | SetHidden Bool
  | SetParameter ParameterAction
  | Delete


{-| Update low-level parameters based on action.
-}
updateParameters : ParameterAction -> Parameters -> Parameters
updateParameters action params =
  case action of
    SetAssimilationDelay d ->
      { params | assimilation_delay = d }

    SetTrainingOverheadProportion p ->
      { params | training_overhead_proportion = p }

    SetInterventions i ->
      { params | interventions = i }


{-| Update simulation based on action.
-}
update : Action -> Simulation -> Simulation
update action model =
  let
    parameters =
      model.parameters
  in
    case action of
      SetName n ->
        { model | name = n }

      SetIncluded i ->
        { model | included = i }

      SetHidden h ->
        { model | hidden = h }

      SetParameter a ->
        { model | parameters = updateParameters a model.parameters }

      _ ->
        model



-- View stuff


{-| Render a button which toggles the hidden state of a simulation's parameters.
-}
hideButton : Signal.Address Action -> Simulation -> Html
hideButton address sim =
  let
    icon =
      if sim.hidden then
        glyphiconChevronRight'
      else
        glyphiconChevronDown'

    params =
      { btnParam | icon = Just (icon "") }
  in
    span
      [ class "input-group-btn" ]
      [ btnDefault' "form-control" params address (SetHidden (not sim.hidden)) ]


{-| Render the controls for a simulations name
-}
nameControls : Signal.Address Action -> Simulation -> Html
nameControls address sim =
  input
    [ type' "text"
    , class "form-control"
    , value sim.name
    , on "input" targetValue (Signal.message address << SetName)
    ]
    []


{-| Render the "included" and "delete" controls for a simulation.
-}
controlButtons : Signal.Address Action -> Simulation -> Html
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


{-| Renders the controls for the assimilation delay parameter
-}
assimilationDelayControls : Signal.Address Action -> Simulation -> List Html
assimilationDelayControls address sim =
  let
    sendSignal =
      String.toInt >> Result.withDefault 0 >> SetAssimilationDelay >> SetParameter >> Signal.message address
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


{-| Renders the controls for the training overhead proportion parameter
-}
trainingOverheadControls : Signal.Address Action -> Simulation -> List Html
trainingOverheadControls address sim =
  let
    sendSignal =
      String.toFloat >> Result.withDefault 0 >> SetTrainingOverheadProportion >> SetParameter >> Signal.message address
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


{-| Renders the controls for the intervention parameter
-}
interventionsControls : Signal.Address Action -> Simulation -> List Html
interventionsControls address sim =
  let
    sendSignal =
      SetInterventions >> SetParameter >> Signal.message address
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


{-| Renders the "main" block of simulation controls. This includes:
    - the hide/show toggle
    - the simulation's name
    - the include and delete controls
-}
mainRow : Signal.Address Action -> Simulation -> List Html
mainRow address sim =
  [ row_
      [ div
          [ class "input-group" ]
          [ hideButton address sim
          , nameControls address sim
          , controlButtons address sim
          ]
      ]
  ]


{-| Render the parameter block, i.e. controls for the low-level parameters.

This is the block that can be hidden/shown.
-}
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
    if sim.hidden then
      []
    else
      result


{-| Render a full view for a single simulation.
-}
view : Signal.Address Action -> Simulation -> Html
view address sim =
  let
    html =
      List.concat
        [ mainRow address sim
        , paramBlock address sim
        ]
  in
    div [] html
