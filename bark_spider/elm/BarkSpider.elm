module BarkSpider where

import BarkSpider.Network exposing (requestSimulation, requestSimulationResults, SimulationResults)
import BarkSpider.Simulation.Actions as SimActions
import BarkSpider.Simulation.Model exposing (createSimulation, simulationToJson, Simulation)
import BarkSpider.Simulation.Update as SimUpdate
import BarkSpider.Simulation.View as SimView
import Bootstrap.Html exposing (..)
import Effects exposing (batch, Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import List
import List.Extra exposing (removeWhen)
import Result exposing (Result)
import StartApp
import String
import Task

--
-- model
--

type alias ID = Int

type alias Model =
  { simulations : List (ID, Simulation)
  , results : String
  , error_messages : List String
  , next_id : Int
  }

createModel : Model
createModel =
  let
    sim = createSimulation "unnamed"
  in
    { simulations = []
    , results = ""
    , error_messages = []
    , next_id = 0
    }

--
-- update
--

type Action
  -- Update the Simulation with the ID
  = Modify ID SimActions.Action

  -- create a new simulation parameter set
  | AddSimulation

  -- send parameter sets to server, requesting simulation. Server responds with
  -- retrieval IDs.
  | RunSimulation

  -- simulation results have arrived and should be displayed.
  | NewResults (List (Result Http.Error SimulationResults))

updateModify : ID -> SimActions.Action -> Model -> Model
updateModify id action model =
  let
    modifySimulation (simId, sim) =
      if simId == id then
        (simId, SimUpdate.update action sim)
      else
        (simId, sim)
    matchId (simId, sim) = simId == id
    sims =
      case action of
        SimActions.Delete ->
          removeWhen matchId model.simulations

        _ ->
          List.map modifySimulation model.simulations
  in
    {model | simulations = sims}

addSimulation : Model -> Model
addSimulation model =
  let
    sim = createSimulation "unnamed"
  in
    { model |
      simulations = model.simulations ++ [ (model.next_id, sim) ]
    , next_id = model.next_id + 1
    }

clearSimulationResults : Model -> Model
clearSimulationResults model =
  { model |
      results = ""
  }

runSimulations : Model -> Effects Action
runSimulations model =
  let
    run (id, sim) =
      requestSimulation sim `Task.andThen` requestSimulationResults
        |> Task.toResult
  in
  -- TODO: Filter out non-included simulations
  List.map run model.simulations
    |> Task.sequence
    |> Task.map NewResults
    |> Effects.task

handleNewResult : Result Http.Error SimulationResults -> Model -> Model
handleNewResult result model =
  case result of
    Ok r ->
      { model
        | results = String.append model.results (toString r)
      }

    Err error ->
      { model
        | error_messages = (toString error) :: model.error_messages
      }

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Modify index action ->
      noFx <| updateModify index action model

    AddSimulation ->
      noFx <| addSimulation model

    RunSimulation ->
      ( clearSimulationResults model
      , runSimulations model
      )

    NewResults results ->
      List.foldl handleNewResult model results |> noFx

--
-- view
--

stylesheet : String -> Html
stylesheet url = node "link" [ rel "stylesheet", href url] []

script : String -> Html
script url = node "script" [src url] []

simView : Signal.Address Action -> (ID, Simulation)  -> Html
simView address (id, sim) = SimView.view (Signal.forwardTo address (Modify id)) sim

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
