module BarkSpider where

import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)
import List

import StartApp

import Bootstrap.Html exposing (..)
import List.Extra exposing (getAt)

import BarkSpider.Simulation as Sim
import BarkSpider.Util exposing (removeAt, setAt)

--
-- model
--

type alias Model =
  { simulations : List Sim.Simulation
  , error_messages : List String
  }

createModel : Model
createModel =
  { simulations = [{name = "sim1", included = True, hidden = False, parameters = {assimilation_delay = 20, training_overhead_proportion = 0.2, interventions = ""}}]
  , error_messages = []
  }

--
-- update
--

type Input = Modify Int Sim.Action | Null

updateModify : Int -> Sim.Action -> Model -> Model
updateModify index action model =
  case action of
    Sim.Delete ->
      {model | simulations = removeAt model.simulations index}

    _ ->
      case getAt model.simulations index of
        Nothing ->
          model

        Just sim ->
          case setAt model.simulations index (Sim.update action sim) of
            Nothing ->
              model -- TODO: Assert...this should never happen...

            Just sims ->
              {model | simulations = sims}

update : Input -> Model -> (Model, Effects Input)
update input model =
  let
    m =
      case input of
        Modify index action ->
          updateModify index action model

        Null ->
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
                   [ btnDefault' "" {btnParam | label = Just "Add parameter set"} address Null
                   , btnDefault' "pull-right" {btnParam | label = Just "Run simulation"} address Null
                   ]
               ]
           , div [] (List.indexedMap (\index sim -> Sim.view (Signal.forwardTo address (Modify index)) sim) model.simulations)
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
