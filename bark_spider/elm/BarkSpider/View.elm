module BarkSpider.View exposing (..)

import BarkSpider.Msg exposing (..)
import BarkSpider.Model as Model
import BarkSpider.Model exposing (ID, Model)
import BarkSpider.Simulation as Sim
import BarkSpider.Util exposing (distinctColorStrings)
import Bootstrap.Html exposing (..)
import Dict
import Html exposing (canvas, div, Html, hr, h1, li, node, text, ul)
import Html.App
import Html.Attributes exposing (class, height, href, id, rel, src, width)
import Plot exposing (..)
import String


stylesheet : String -> Html Msg
stylesheet url =
    node "link" [ rel "stylesheet", href url ] []


script : String -> Html Msg
script url =
    node "script" [ src url ] []


simView : ( ID, Sim.Simulation ) -> Html Msg
simView ( id, sim ) =
    Html.App.map (UpdateSimulation id) (Sim.view sim)



-- resultToSeries : SimulationResults -> (Float -> Color) -> Series
-- resultToSeries result color =
--   ( result.name
--   , defStyle color
--   , Dict.values result.data.software_development_rate
--   )
-- resultsToChart : List SimulationResults -> Html Msg
-- resultsToChart results =
--   let
--     res1 =
--       List.head results
--   in
--     case res1 of
--       Just res ->
--         let
--           config =
--             ( Dict.values res.data.elapsed_time |> List.map toString
--             , List.map2 resultToSeries results distinctColors
--             )
--           options =
--             { defaultOptions
--               | animation = False
--               , pointDot = False
--             }
--         in
--           chart 1000 1000 config options
--             |> fromElement
--       -- TODO: Insert legend. We need to add support for legends to the chartjs bindings.
--       Nothing ->
--         div [] []


errorList : Model -> Html Msg
errorList model =
    row_ <|
        List.map
            (\err ->
                div [ class "alert alert-warning" ]
                    [ text err ]
            )
        <|
            model.error_messages


{-| Get all of the data from successful simulation results in a model.
-}
simulationData : Model -> List (List ( Float, Float ))
simulationData model =
    List.foldl
        (\status results ->
            case status of
                Model.Success data ->
                    (List.map (\( e, d ) -> ( toFloat (e), d )) data) :: results

                _ ->
                    results
        )
        []
        (Dict.values model.results)


renderPlot : Model -> Html Msg
renderPlot model =
    let
        datasets =
            simulationData model

        dataPlots =
            List.map2
                (\dataset color ->
                    area [ areaStyle [ ( "fill-opacity", "0.5" ), ( "fill", color ), ( "stroke", color ) ] ] dataset
                )
                datasets
                distinctColorStrings
    in
        plot
            [ padding ( 100, 100 ) ]
            ([ yAxis [ axisLineStyle [ ( "stroke", "#b9b9b9" ) ] ]
             , xAxis [ axisLineStyle [ ( "stroke", "#b9b9b9" ) ] ]
             ]
                ++ dataPlots
            )


view : Model -> Html Msg
view model =
    containerFluid_
        [ row_
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
                        [ btnDefault' "" { btnParam | label = Just "Add parameter set" } (AddSimulation (Sim.createSimulation "unnamed"))
                        , btnDefault' "pull-right btn-primary" { btnParam | label = Just "Run simulation" } RunSimulations
                        ]
                    ]
                 , hr [] []
                 ]
                    ++ List.map simView model.simulations
                )
            , colMd_
                8
                8
                8
                [ errorList model
                  -- , canvas [ id "bark-spider-canvas", height 1000, width 1000 ] []
                , renderPlot model
                , text (String.concat model.error_messages)
                ]
            ]
        ]
