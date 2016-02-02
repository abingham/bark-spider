module BarkSpider where

import BarkSpider.Simulation.Actions as SimActions
import BarkSpider.Simulation.Model exposing (createSimulation, simulationToJson, Simulation)
import BarkSpider.Simulation.Update as SimUpdate
import BarkSpider.Simulation.View as SimView
import Bootstrap.Html exposing (..)
import Effects exposing (batch, Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Http.Extra
import Json.Decode
import Json.Encode
import List
import List.Extra exposing (removeWhen)
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
  = Modify ID SimActions.Action
  | AddSimulation
  | RunSimulation
  | NewResults (Result Http.Error String)

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

requestSimulation : Simulation -> Effects Action
requestSimulation sim =
  let
    convertError = flip Task.onError <| Task.succeed << toString
    url = "/simulate"
  in
    Http.Extra.post url
      |> Http.Extra.withBody (Http.string (Json.Encode.encode 2 (simulationToJson sim)))
      |> Http.Extra.withHeader ("Content-Type", "application/json")

      |> Http.Extra.send (Json.Decode.dict Json.Decode.string)

      -- Convert the dict of strings to just a string
      |> Task.map toString

      -- Turn it into a Result
      |> Task.toResult
      |> Task.map NewResults
      |> Effects.task

requestSimulations : Model -> Effects Action
requestSimulations model =
  -- TODO: Obviously this is just a placeholder. We need to:
  --   1. Find all parameters sets which are "included"
  --   2. Fetch results for each one individually
  --   3. When they all arrive, update the chart/UI.
  List.map (snd >> requestSimulation) model.simulations |> batch

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Modify index action ->
      noFx <| updateModify index action model

    AddSimulation ->
      noFx <| addSimulation model

    RunSimulation ->
      ( clearSimulationResults model
      , requestSimulations model
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
