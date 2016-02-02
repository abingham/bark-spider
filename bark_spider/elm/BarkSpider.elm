module BarkSpider where

import BarkSpider.Simulation as Sim
import Bootstrap.Html exposing (..)
import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Http.Extra
import Json.Decode
import List
import List.Extra exposing (removeWhen)
import StartApp
import String
import Task

--
-- model
--

type alias ID = Int

type alias ViewState =
  { opened : Bool
  }

type alias Model =
  { simulations : List (ID, ViewState, Sim.Simulation)
  , results : String
  , error_messages : List String
  , next_id : Int
  }

createModel : Model
createModel =
  let
    sim = Sim.createSimulation "unnamed"
  in
    { simulations = [(0, {opened = True}, sim)]
    , results = ""
    , error_messages = []
    , next_id = 1
    }

--
-- update
--

type Action
  = Modify ID Sim.Action
  | AddSimulation
  | RunSimulation
  | NewResults (Result Http.Error String)

updateModify : ID -> Sim.Action -> Model -> Model
updateModify id action model =
  let
    modifySimulation (simId, viewState, sim) =
      if simId == id then
        (simId, viewState, Sim.update action sim)
      else
        (simId, viewState, sim)
    matchId (simId, viewState, sim) = simId == id
    sims =
      case action of
        Sim.Delete ->
          removeWhen matchId model.simulations

        _ ->
          List.map modifySimulation model.simulations
  in
    {model | simulations = sims}

addSimulation : Model -> Model
addSimulation model =
  let
    sim = Sim.createSimulation "unnamed"
    viewState = { opened = True }
  in
    { model |
      simulations = model.simulations ++ [ (model.next_id, viewState, sim) ]
    , next_id = model.next_id + 1
    }

runSimulation : Model -> Model
runSimulation model =
  { model |
      results = ""
  }

getSimulationResults : Model -> Effects Action
getSimulationResults model =
  -- TODO: Obviously this is just a placeholder. We need to:
  --   1. Find all parameters sets which are "included"
  --   2. Fetch results for each one individually
  --   3. When they all arrive, update the chart/UI.
  let
    convertError = flip Task.onError <| Task.succeed << toString
    url = "http://ip.jsontest.com/"
  in
    Http.Extra.get url
      -- fetch JSON data. It's a dict of strings, hence the parser
      |> Http.Extra.send (Json.Decode.dict Json.Decode.string)

      -- Convert the dict of strings to just a string
      |> Task.map toString

      -- Turn it into a Result
      |> Task.toResult
      |> Task.map NewResults
      |> Effects.task

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Modify index action ->
      noFx <| updateModify index action model

    AddSimulation ->
      noFx <| addSimulation model

    RunSimulation ->
      ( runSimulation model
      , getSimulationResults model
      )

    NewResults (Ok value) ->
      noFx <| { model
                | results = String.append model.results value
              }

    NewResults (Err error) ->
      noFx <| { model
                | error_messages = (toString error) :: model.error_messages
              }


--
-- view
--

stylesheet : String -> Html
stylesheet url = node "link" [ rel "stylesheet", href url] []

script : String -> Html
script url = node "script" [src url] []

simView : Signal.Address Action -> (ID, ViewState, Sim.Simulation)  -> Html
simView address (id, viewState, sim) = Sim.view (Signal.forwardTo address (Modify id)) sim

view : Signal.Address Action -> Model -> Html
view address model =
    containerFluid_
    [ stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"
    , stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css"
    , script "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/1.0.2/Chart.min.js"
    , row_
        [colMd_ 12 12 12
           [ h1 [] [text "Simulation Parameters"]
           , row_
               [ colMd_ 12 12 12
                   [ btnDefault' "" {btnParam | label = Just "Add parameter set"} address AddSimulation
                   , btnDefault' "pull-right" {btnParam | label = Just "Run simulation"} address RunSimulation
                   ]
               ]
           , div [] (List.map (simView address) model.simulations)
           ]
        ]
    , row_
        [colMd_ 12 12 12
           [ text model.results
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

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks
