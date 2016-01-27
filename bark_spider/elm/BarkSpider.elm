module BarkSpider where

import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)
import List

import StartApp

import Bootstrap.Html exposing (..)

--
-- model
--

type alias Parameters =
  { assimilation_delay : Int
  , training_overhead_proportion : Float
  , interventions : String
  }

type alias Simulation =
  { name : String
  , included : Bool
  , parameters : Parameters
  }

type alias Model =
  { simulations : List Simulation
  , error_messages : List String
  }

createModel : Model
createModel =
  { simulations = [{name = "sim1", included = True, parameters = {assimilation_delay = 20, training_overhead_proportion = 0.2, interventions = ""}}]
  , error_messages = []
  }

--
-- update
--

type Input = Nothing

update : Input -> Model -> (Model, Effects Input)
update input model =
  let
    m =
      case input of
        Nothing ->
          model
  in
    noFx m

--
-- view
--

stylesheet : String -> Html
stylesheet url = node "link" [ rel "stylesheet", href url] []

script : String -> Html
script url = node "script" [src url] []

simulationRow : Signal.Address Input -> Simulation -> Html
simulationRow address sim =
  let
    icon = { btnParam | icon = Just (glyphiconChevronDown' "") }
  in
    row_
         [ div [class "input-group"]
             [ span [class "input-group-btn"]
                 [ btnDefault' "form-control" icon address Nothing
                     
                 ]
                 
             ]
             
         ]

view : Signal.Address Input -> Model -> Html
view address model =
    containerFluid_
    [ stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"
    , stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css"
    , script "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/1.0.2/Chart.min.js"
    , row_
        [colMd_ 4 4 4
           [ h1 [] [text "Simulation Parameters"]
           , row_
               [ colMd_ 12 12 12
                   [ btnDefault' "" {btnParam | label = Just "Add parameter set"} address Nothing
                   , btnDefault' "pull-right" {btnParam | label = Just "Run simulation"} address Nothing
                   ]
               ]
           , div [] (List.map (simulationRow address) model.simulations)
           ]
        , colMd_ 6 6 6
           [ text "emus"
           , text "platypuses...platypi? Not sure."
           ]
        ]
    ]

--
-- Utilities
--

noFx : model -> (model, Effects a)
noFx model = (model, Effects.none)

--
-- Main stuff
--

app : StartApp.App Model
app = StartApp.start
      { init = noFx (createModel)
      , view = view
      , update = update
      , inputs = []
      }

main : Signal Html
main = app.html
