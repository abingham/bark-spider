module BarkSpider.Update where

import BarkSpider.Actions exposing (..)
import BarkSpider.Model exposing (ID, Model)
import BarkSpider.Network exposing (runSimulation, SimulationResults)
import BarkSpider.Simulation.Actions as SimActions
import BarkSpider.Simulation.Model exposing (createSimulation)
import BarkSpider.Simulation.Update as SimUpdate
import BarkSpider.Util exposing (noFx)
import Effects exposing (Effects)
import Http
import List
import List.Extra exposing (removeWhen)
import Result exposing (Result)
import String
import Task

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
    sims =
      List.map snd model.simulations
        |> List.filter .included
  in
    List.map (runSimulation >> Task.toResult) sims
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
      updateModify index action model
        |> noFx

    AddSimulation ->
      addSimulation model
        |> noFx

    RunSimulation ->
      ( clearSimulationResults model
      , runSimulations model
      )

    NewResults results ->
      List.foldl handleNewResult model results
        |> noFx
