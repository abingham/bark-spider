module BarkSpider.Comms exposing (..)

{-| Functions for requesting simulation execution and results from the server.
This implements the HTTP+JSON protocol that the server uses.
-}

import BarkSpider.Json exposing (..)
import BarkSpider.Model exposing (ID, Model, SimulationData, URL)
import BarkSpider.Msg as Msg
import BarkSpider.Simulation exposing (Parameters, Simulation, simulationToJson)
import Http
import Json.Decode exposing (string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Platform.Cmd
import Process
import Task
import Time


--
-- HTTP API
--


{-| Convert an HTTP error to human-readable string.
-}
errorToString : Http.Error -> String
errorToString err =
    case err of
        Http.UnexpectedPayload msg ->
            msg

        Http.NetworkError ->
            "Network error"

        Http.Timeout ->
            "Timeout"

        Http.BadResponse i r ->
            r


{-| Phase 1 of the simulation request. Ask the server to do the simulation and
 hand back a results URL/ID.
-}
requestSimulation : ID -> Simulation -> Platform.Cmd.Cmd Msg.Msg
requestSimulation id sim =
    let
        -- convertError = flip Task.onError <| Task.succeed << toString
        url =
            Http.url "/simulate" []

        body =
            (Http.string (Json.Encode.encode 2 (simulationToJson sim)))

        task =
            Http.post
                (decode identity |> required "url" string)
                url
                body
    in
        Task.perform
            (errorToString >> Msg.SimulationError id)
            (Msg.SimulationSuccess id)
            task


{-| Phase 2 of the simulation request. Ask the server for the results.
-}
requestSimulationResults : ID -> URL -> Time.Time -> Platform.Cmd.Cmd Msg.Msg
requestSimulationResults id status_url wait =
    let
        url =
            Http.url status_url []

        sleep =
            Process.sleep wait

        task =
            Http.get
                (simulationStatusDecoder status_url)
                url
    in
        Task.perform
            (errorToString >> Msg.SimulationStatusError id)
            (Msg.SimulationStatusSuccess id)
            (sleep `Task.andThen` (\_ -> task))


{-| Launch all simulations in a model, resulting in a `NewResults` Msg.
-}
runSimulations : Model -> List (Platform.Cmd.Cmd Msg.Msg)
runSimulations model =
    let
        included =
            List.filter (snd >> .included) model.simulations
    in
        List.map (\s -> requestSimulation (fst s) (snd s)) included
