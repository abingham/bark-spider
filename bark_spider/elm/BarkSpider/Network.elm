-- Functions for requesting simulation execution and results from the server.
-- This implements the HTTP+JSON protocol that the server uses.

module BarkSpider.Network where

import BarkSpider.Simulation.Model exposing (Simulation, simulationToJson)
import Http
import Http.Extra exposing (get, post, send, withBody, withHeader)
import Json.Decode
import Json.Decode exposing ((:=))
import Json.Encode
import String
import Task

-- This is what we get back when we request that a simulation be run
type alias RequestResponse =
  { url : String       -- The URL at which the results can be fetched
  , result_id : String -- The ID of the results (append to the url)
  }

-- These are the actual simulation results.
type alias SimulationResults =
  { name : String        -- Name assigned to the results
  , parameters : String  -- Parameters used to calculate the results
  , results : String     -- The results themselves
  }

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
      ("parameters" := Json.Decode.string)
      ("results" := Json.Decode.string)

requestSimulation : Simulation -> Task.Task Http.Error RequestResponse
requestSimulation sim =
  let
    -- convertError = flip Task.onError <| Task.succeed << toString
    url = Http.url "/simulate" []
    body = (Http.string (Json.Encode.encode 2 (simulationToJson sim)))
    header = ("Content-Type", "application/json")
  in
    post url
      |> withBody body
      |> withHeader header
      |> send requestResponseDecoder

      -- |> Task.toResult
      -- |> Task.map NewResults
      -- |> Effects.task

requestSimulationResults : RequestResponse -> Task.Task Http.Error SimulationResults
requestSimulationResults reqResponse =
  let
    address = String.concat [reqResponse.url, "/", reqResponse.result_id]
    url = Http.url address []
  in
    get url
      |> send simulationResultsDecoder
