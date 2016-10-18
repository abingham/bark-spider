module BarkSpider.View exposing (..)

import BarkSpider.Msg exposing (..)
import BarkSpider.Model exposing (ID, Model, SimulationResults)
import BarkSpider.Simulation as Sim


-- import BarkSpider.Util exposing (distinctColors)

import Bootstrap.Html exposing (..)


-- import Color exposing (..)
-- import Dict

import Html exposing (canvas, div, Html, hr, h1, node, text)
import Html.App
import Html.Attributes exposing (height, href, id, rel, src, width)


-- import Html.Lazy

import String


stylesheet : String -> Html Msg
stylesheet url =
    node "link" [ rel "stylesheet", href url ] []


script : String -> Html Msg
script url =
    node "script" [ src url ] []


simView : ( ID, Sim.Simulation ) -> Html Msg
simView ( id, sim ) =
    Html.App.map (Modify id) (Sim.view sim)



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
                        , btnDefault' "pull-right btn-primary" { btnParam | label = Just "Run simulation" } RunSimulation
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
                [ canvas [ id "bark-spider-canvas", height 1000, width 1000 ] []
                , text (String.concat model.error_messages)
                ]
            ]
        ]
