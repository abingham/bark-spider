module BarkSpider.Simulation exposing (..)

import Json.Encode exposing (int, float, object, string, Value)
import Bootstrap.Html exposing (btnDefault', btnParam, colSm_, glyphiconChevronDown', glyphiconChevronRight', row_)
import Html exposing (div, Html, input, label, span, text, textarea)
import Html.Attributes exposing (class, type', value)
import Html.Events exposing (onInput)
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


{-| Msgs for modifying low-level parameters
-}
type SetParameterMsg
    = SetAssimilationDelay Int
    | SetTrainingOverheadProportion Float
    | SetInterventions String


{-| Msgs for modifying high-level parameters
-}
type Msg
    = SetName String
    | SetIncluded Bool
    | SetHidden Bool
    | SetParameter SetParameterMsg
    | Delete


{-| Update low-level parameters based on action.
-}
updateParameters : SetParameterMsg -> Parameters -> Parameters
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
update : Msg -> Simulation -> Simulation
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
hideButton : Simulation -> Html Msg
hideButton sim =
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
            [ btnDefault' "form-control" params (SetHidden (not sim.hidden)) ]


{-| Render the controls for a simulations name
-}
nameControls : Simulation -> Html Msg
nameControls sim =
    input
        [ type' "text"
        , class "form-control"
        , value sim.name
        , onInput SetName
        ]
        []


{-| Render the "included" and "delete" controls for a simulation.
-}
controlButtons : Simulation -> Html Msg
controlButtons sim =
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
            [ btnDefault' "" included_text (SetIncluded (not sim.included))
            , btnDefault' "" delete_text Delete
            ]


{-| Renders the controls for the assimilation delay parameter
-}
assimilationDelayControls : Simulation -> List (Html Msg)
assimilationDelayControls sim =
    let
        sendSignal =
            String.toInt >> Result.withDefault 0 >> SetAssimilationDelay >> SetParameter
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
                    , onInput sendSignal
                    ]
                    []
                ]
            ]
        ]


{-| Renders the controls for the training overhead proportion parameter
-}
trainingOverheadControls : Simulation -> List (Html Msg)
trainingOverheadControls sim =
    let
        sendSignal =
            String.toFloat >> Result.withDefault 0 >> SetTrainingOverheadProportion >> SetParameter
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
                    , onInput sendSignal
                    ]
                    []
                ]
            ]
        ]


{-| Renders the controls for the intervention parameter
-}
interventionsControls : Simulation -> List (Html Msg)
interventionsControls sim =
    let
        sendSignal =
            SetInterventions >> SetParameter
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
                    , onInput sendSignal
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
mainRow : Simulation -> List (Html Msg)
mainRow sim =
    [ row_
        [ div
            [ class "input-group" ]
            [ hideButton sim
            , nameControls sim
            , controlButtons sim
            ]
        ]
    ]


{-| Render the parameter block, i.e. controls for the low-level parameters.

This is the block that can be hidden/shown.
-}
paramBlock : Simulation -> List (Html Msg)
paramBlock sim =
    let
        html =
            [ assimilationDelayControls sim
            , trainingOverheadControls sim
            , interventionsControls sim
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
view : Simulation -> Html Msg
view sim =
    let
        html =
            List.concat
                [ mainRow sim
                , paramBlock sim
                ]
    in
        div [] html
