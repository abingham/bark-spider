module BarkSpider.Update (..) where

import BarkSpider.Actions exposing (..)
import BarkSpider.Model exposing (ID, Model, SimulationResults)
import BarkSpider.Comms exposing (runSimulation)
import BarkSpider.Simulation as Sim
import BarkSpider.Util exposing (noFx)
import Effects exposing (Effects)
import Http
import List
import List.Extra exposing (removeWhen)
import Result exposing (Result)
import Task


updateModify : ID -> Sim.Action -> Model -> Model
updateModify id action model =
  let
    modifySimulation ( simId, sim ) =
      if simId == id then
        ( simId, Sim.update action sim )
      else
        ( simId, sim )

    matchId ( simId, sim ) =
      simId == id

    sims =
      case action of
        Sim.Delete ->
          removeWhen matchId model.simulations

        _ ->
          List.map modifySimulation model.simulations
  in
    { model | simulations = sims }


addSimulation : Model -> Sim.Simulation -> Model
addSimulation model sim =
  { model
    | simulations = model.simulations ++ [ ( model.next_id, sim ) ]
    , next_id = model.next_id + 1
  }


clearSimulationResults : Model -> Model
clearSimulationResults model =
  { model
    | results = []
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
        | results = r :: model.results
      }

    Err error ->
      { model
        | error_messages = (toString error) :: model.error_messages
      }


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Modify index action ->
      updateModify index action model
        |> noFx

    AddSimulation sim ->
      addSimulation model sim
        |> noFx

    RunSimulation ->
      ( clearSimulationResults model
      , runSimulations model
      )

    NewResults results ->
      List.foldl handleNewResult model results
        |> noFx
