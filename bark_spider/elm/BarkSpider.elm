module BarkSpider where

import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)
import List

import StartApp

import Bootstrap.Html exposing (..)
import List.Extra exposing (getAt, removeWhen)

import BarkSpider.Simulation as Sim

--
-- model
--

type alias ID = Int

type alias Model =
  { simulations : List (ID, Sim.Simulation)
  , error_messages : List String
  , next_id : Int
  }

createModel : Model
createModel =
  let
    params = {assimilation_delay = 20, training_overhead_proportion = 0.2, interventions = ""}
    sim = {name = "sim1", included = True, hidden = False, parameters = params}
  in
    { simulations = [(0, sim)]
    , error_messages = []
    , next_id = 1
    }

--
-- update
--

type Action
  = Modify ID Sim.Action
  | Null

updateModify : ID -> Sim.Action -> Model -> Model
updateModify id action model =
  let
    modifySimulation (simId, sim) =
      if simId == id then
        (simId, Sim.update action sim)
      else
        (simId, sim)
    matchId (simId, sim) = simId == id
    sims = 
      case action of
        Sim.Delete ->
          removeWhen matchId model.simulations

        _ ->
          List.map modifySimulation model.simulations
  in
    {model | simulations = sims}

update : Action -> Model -> (Model, Effects Action)
update action model =
  let
    m =
      case action of
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

simView : Signal.Address Action -> (ID, Sim.Simulation)  -> Html
simView address (id, sim) = Sim.view (Signal.forwardTo address (Modify id)) sim

view : Signal.Address Action -> Model -> Html
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
           , div [] (List.map (simView address) model.simulations)
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
