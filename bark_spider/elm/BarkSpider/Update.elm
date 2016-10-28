module BarkSpider.Update exposing (..)

import BarkSpider.Chart as Chart
import BarkSpider.Msg exposing (..)
import BarkSpider.Model exposing (ID, Model, SimulationResults)
import BarkSpider.Comms as Comms
import BarkSpider.Simulation as Sim
import Http
import List
import List.Extra exposing (filterNot)
import Result exposing (Result)
import Return exposing (command, map, Return, singleton)


{-| Update the simulation parameters by ID based on an .
-}
updateSimulation : ID -> Sim.Msg -> Model -> Model
updateSimulation id action model =
    let
        updateSimulation ( simId, sim ) =
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
                    List.map updateSimulation model.simulations
    in
        { model | simulations = sims }


{-| Add a simulation to a model using the next available ID.
-}
addSimulation : Sim.Simulation -> Model -> Model
addSimulation sim model =
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
update : Msg -> Model -> Return Msg Model
update action model =
    singleton model
        |> case action of
            UpdateSimulation index action ->
                map (updateSimulation index action)

            AddSimulation sim ->
                map (addSimulation sim)

            RunSimulation ->
                map clearSimulationResults
                    >> command (Comms.runSimulations model)

            NewResults results ->
                map (\m -> List.foldl handleNewResult m results)
                    >> command (Chart.plot results)
