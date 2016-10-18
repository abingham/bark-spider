module BarkSpider.Update exposing (..)

import BarkSpider.Chart as Chart
import BarkSpider.Msg exposing (..)
import BarkSpider.Model exposing (ID, Model, SimulationResults)
import BarkSpider.Comms exposing (runSimulation)
import BarkSpider.Simulation as Sim
import BarkSpider.Util exposing (noFx)
import Http
import List
import List.Extra exposing (filterNot)
import Platform.Cmd
import Result exposing (Result)
import Task
import Task.Extra exposing (performFailproof)


{-| Update the simulation parameters by ID based on an .
-}
updateModify : ID -> Sim.Msg -> Model -> Model
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
                    filterNot matchId model.simulations

                _ ->
                    List.map modifySimulation model.simulations
    in
        { model | simulations = sims }


{-| Add a simulation to a model using the next available ID.
-}
addSimulation : Model -> Sim.Simulation -> Model
addSimulation model sim =
    { model
        | simulations = model.simulations ++ [ ( model.next_id, sim ) ]
        , next_id = model.next_id + 1
    }


{-| Remove all simulation results from a model.
-}
clearSimulationResults : Model -> Model
clearSimulationResults model =
    { model
        | results = []
    }


{-| Launch all simulations in a model as Effects that come back as NewResults
actions.
-}
runSimulations : Model -> Platform.Cmd.Cmd Msg
runSimulations model =
    let
        sims =
            List.map snd model.simulations
                |> List.filter .included

        task =
            List.map (runSimulation >> Task.toResult) sims
                |> Task.sequence
    in
        -- TODO: This feels like a hack. The task.perform should never fail
        -- (because of task.toResult above, failure here is meaningless). But task
        -- perform requires *something* in this slot. Are we doing this wrong?
        performFailproof
            NewResults
            task


{-| Append simulation results (or errors) to a model.
-}
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


{-| Update a model and/or launch effects based on an action.
-}
update : Msg -> Model -> ( Model, Platform.Cmd.Cmd Msg )
update action model =
    case action of
        Modify index action ->
            updateModify index action model
                |> noFx

        AddSimulation sim ->
            addSimulation model sim |> noFx

        RunSimulation ->
            ( clearSimulationResults model
            , runSimulations model
            )

        NewResults results ->
            ( List.foldl handleNewResult model results
            , Chart.plot results
            )
