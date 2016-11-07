module BarkSpider.Comms exposing (..)

{-| Functions for requesting simulation execution and results from the server.
This implements the HTTP+JSON protocol that the server uses.
-}

import BarkSpider.Json exposing (..)
import BarkSpider.Model exposing (ID, Model, SimulationData, SimulationResults)
import BarkSpider.Msg as Msg
import BarkSpider.Simulation exposing (Parameters, Simulation, simulationToJson)
import Http
import Json.Encode
import Platform.Cmd
import Task

--
-- HTTP API
--


{-| Phase 1 of the simulation request. Ask the server to do the simulation and
 hand back a results URL/ID.
-}
requestSimulation : ID -> Simulation ->  Platform.Cmd.Cmd Msg.Msg
requestSimulation id sim =
    let
        -- convertError = flip Task.onError <| Task.succeed << toString
        url =
            Http.url "/simulate" []

        body =
            (Http.string (Json.Encode.encode 2 (simulationToJson sim)))

        task =
            Http.post
                requestResponseDecoder
                url
                body
    in
        Task.perform
            (Msg.SimulationError id)
            (Msg.SimulationSuccess id)
            task


{-| Phase 2 of the simulation request. Ask the server for the results.
-}
requestSimulationResults : ID -> String -> Platform.Cmd.Cmd Msg.Msg
requestSimulationResults id address =
    let
        url =
            Http.url address []

        task =
            Http.get
                simulationStatusDecoder
                url
    in
        Task.perform
            (Msg.SimulationStatusError id)
            (Msg.SimulationStatusSuccess id)
            task


{-| Launch all simulations in a model, resulting in a `NewResults` Msg.
-}
runSimulations : Model -> List (Platform.Cmd.Cmd Msg.Msg)
runSimulations model =
    let
        included =
            List.filter (snd >> .included) model.simulations
    in
        List.map (\s -> requestSimulation (fst s) (snd s)) included
