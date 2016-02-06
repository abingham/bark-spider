module BarkSpider.View (..) where

import BarkSpider.Actions exposing (..)
import BarkSpider.Model exposing (ID, Model, SimulationResults)
import BarkSpider.Simulation.Model exposing (Simulation)
import BarkSpider.Simulation.View as SimView
import Bootstrap.Html exposing (..)
import Chartjs.Line exposing (..)
import Color exposing (..)
import Dict
import Html exposing (div, fromElement, Html, hr, h1, node, text)
import Html.Attributes exposing (href, rel, src)
import String


stylesheet : String -> Html
stylesheet url =
  node "link" [ rel "stylesheet", href url ] []


script : String -> Html
script url =
  node "script" [ src url ] []


simView : Signal.Address Action -> ( ID, Simulation ) -> Html
simView address ( id, sim ) =
  SimView.view (Signal.forwardTo address (Modify id)) sim


resultToConfig : SimulationResults -> Series
resultToConfig result =
  ( result.name
  , defStyle (rgba 220 220 220)
  , Dict.values result.data.software_development_rate
  )


resultsToChart : List SimulationResults -> Html
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
            , List.map resultToConfig results
            )

          options =
            { defaultOptions | animation = False }
        in
          chart 1000 1000 config options
            |> fromElement

      Nothing ->
        div [] []


view : Signal.Address Action -> Model -> Html
view address model =
  containerFluid_
    [ stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"
    , stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css"
    , script "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"
    , script "https://code.jquery.com/jquery-2.1.4.min.js"
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
                    [ btnDefault' "" { btnParam | label = Just "Add parameter set" } address AddSimulation
                    , btnDefault' "pull-right btn-primary" { btnParam | label = Just "Run simulation" } address RunSimulation
                    ]
                ]
             , hr [] []
             ]
              ++ List.map (simView address) model.simulations
            )
        , colMd_
            8
            8
            8
            [ resultsToChart model.results
            , text (String.concat model.error_messages)
            ]
        ]
    ]
