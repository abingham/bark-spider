module BarkSpider.Comms exposing (..)

{-| Functions for requesting simulation execution and results from the server.
This implements the HTTP+JSON protocol that the server uses.
-}

import BarkSpider.Json exposing (..)
import BarkSpider.Model exposing (Model, SimulationData, SimulationResults)
import BarkSpider.Msg as Msg
import BarkSpider.Simulation exposing (Parameters, Simulation, simulationToJson)
import Dict
import Http
import Json.Decode
import Json.Decode exposing ((:=), dict, int, float, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Platform.Cmd
import Task
import Task.Extra exposing (performFailproof)


--
-- Data types
--


{-| This is what we get back when we request that a simulation be run
-}
type alias RequestResponse =
    { url :
        String
        -- The URL at which the results can be fetched
    , result_id :
        String
        -- The ID of the results (append to the url)
    }



-- This is what we get back as simulation results:
--
-- {"results":
--   {"software_development_rate": {"<step>": "<rate (float)>", . . .},
--    "step_number": {"<step>": "<step>", . . .},
--    "elapsed_time": {"<step>": "<elapsed time (int)>", . . .}},
--  "parameters": {"interventions": "add 100 10", "assimilation_delay": 20, "training_overhead_proportion": 0.25}, "name": "+10 @ 100d"}
--
-- JSON decoders
--


requestResponseDecoder : Json.Decode.Decoder RequestResponse
requestResponseDecoder =
    let
        toResponse url result_id =
            { url = url
            , result_id = result_id
            }
    in
        decode RequestResponse
            |> required "url" string
            |> required "result-id" string


parametersDecoder : Json.Decode.Decoder Parameters
parametersDecoder =
    let
        toParameter a t i =
            { assimilation_delay = a
            , training_overhead_proportion = t
            , interventions = i
            }
    in
        decode Parameters
            |> required "assimilation_delay" int
            |> required "training_overhead_proportion" float
            |> required "interventions" string


simulationDataDecoder : Json.Decode.Decoder SimulationData
simulationDataDecoder =
    let
        keys =
            toIntKeys >> Dict.values

        toResults rates times =
            List.map2 (,) (keys times) (keys rates)
    in
        decode toResults
            |> required "software_development_rate" (dict stringFloatDecoder)
            |> required "elapsed_time" (dict stringIntDecoder)


simulationResultsDecoder : Json.Decode.Decoder SimulationResults
simulationResultsDecoder =
    let
        toResults name parameters data =
            { name = name
            , parameters = parameters
            , data = data
            }
    in
        decode toResults
            |> required "name" string
            |> required "parameters" parametersDecoder
            |> required "results" simulationDataDecoder



--
-- HTTP API
--


{-| Phase 1 of the simulation request. Ask the server to do the simulation and
 hand back a results URL/ID.
-}
requestSimulation : Simulation -> Task.Task Http.Error RequestResponse
requestSimulation sim =
    let
        -- convertError = flip Task.onError <| Task.succeed << toString
        url =
            Http.url "/simulate" []

        body =
            (Http.string (Json.Encode.encode 2 (simulationToJson sim)))
    in
        Http.post
            requestResponseDecoder
            url
            body


{-| Phase 2 of the simulation request. Ask the server for the results.
-}
requestSimulationResults : RequestResponse -> Task.Task Http.Error SimulationResults
requestSimulationResults reqResponse =
    let
        address =
            reqResponse.url

        url =
            Http.url address []
    in
        Http.get
            simulationResultsDecoder
            url



{-| Launch all simulations in a model, resulting in a `NewResults` Msg.
-}
runSimulations : Model -> Platform.Cmd.Cmd Msg.Msg
runSimulations model =
    let
        sims =
            List.map snd model.simulations
                |> List.filter .included

        runSim sim =
            requestSimulation sim `Task.andThen` requestSimulationResults

        task =
            List.map (runSim >> Task.toResult) sims
                |> Task.sequence
    in
        performFailproof
            Msg.NewResults
            task
