-- Functions for requesting simulation execution and results from the server.
-- This implements the HTTP+JSON protocol that the server uses.


module BarkSpider.Network (..) where

import BarkSpider.Json exposing (..)
import BarkSpider.Simulation.Model exposing (Parameters, Simulation, simulationToJson)
import Dict
import Http
import Http.Extra exposing (get, post, send, withBody, withHeader)
import Json.Decode
import Json.Decode exposing ((:=))
import Json.Encode
import Task


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


{-| The "data" payload of a simulation
-}
type alias SimulationData =
  { software_development_rate : Dict.Dict Int Float
  , elapsed_time : Dict.Dict Int Int
  }


{-| The top-level simulation results, including metadata, parameters, and data.
-}
type alias SimulationResults =
  { name :
      String
      -- Name assigned to the results
  , parameters :
      Parameters
      -- Parameters used to calculate the results
  , results :
      SimulationData
      -- The results themselves
  }



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
    Json.Decode.object2
      toResponse
      ("url" := Json.Decode.string)
      ("result-id" := Json.Decode.string)


parametersDecoder : Json.Decode.Decoder Parameters
parametersDecoder =
  let
    toParameter a t i =
      { assimilation_delay = a
      , training_overhead_proportion = t
      , interventions = i
      }
  in
    Json.Decode.object3
      toParameter
      ("assimilation_delay" := Json.Decode.int)
      ("training_overhead_proportion" := Json.Decode.float)
      ("interventions" := Json.Decode.string)


simulationDataDecoder : Json.Decode.Decoder SimulationData
simulationDataDecoder =
  let
    toResults s e =
      { software_development_rate = toIntKeys s
      , elapsed_time = toIntKeys e
      }
  in
    Json.Decode.object2
      toResults
      ("software_development_rate" := Json.Decode.dict stringFloatDecoder)
      ("elapsed_time" := Json.Decode.dict stringIntDecoder)


simulationResultsDecoder : Json.Decode.Decoder SimulationResults
simulationResultsDecoder =
  let
    toResults name parameters results =
      { name = name
      , parameters = parameters
      , results = results
      }
  in
    Json.Decode.object3
      toResults
      ("name" := Json.Decode.string)
      ("parameters" := parametersDecoder)
      ("results" := simulationDataDecoder)



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

    header =
      ( "Content-Type", "application/json" )
  in
    post url
      |> withBody body
      |> withHeader header
      |> send requestResponseDecoder


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
    get url
      |> send simulationResultsDecoder


{-| Combine phasese 1 and 2...probably what you want.
-}
runSimulation : Simulation -> Task.Task Http.Error SimulationResults
runSimulation sim =
  requestSimulation sim `Task.andThen` requestSimulationResults
