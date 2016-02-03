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

type alias RequestResponse =
  { url : String -- TODO: Is there a more official URL type?
  , result_id : String
  }

type alias SimulationResults =
  { name : String
  , parameters : String
  , results : String
  }

requestResponseDecoder : Json.Decode.Decoder RequestResponse
requestResponseDecoder =
  let
    toResponse url result_id = { url = url, result_id = result_id }
  in
    Json.Decode.object2 toResponse ("url" := Json.Decode.string) ("result-id" := Json.Decode.string)

simulationResultsDecoder : Json.Decode.Decoder SimulationResults
simulationResultsDecoder =
  let
    toResults name parameters results = { name = name, parameters = parameters, results = results }
  in
    Json.Decode.object3 toResults ("name" := Json.Decode.string) ("parameters" := Json.Decode.string) ("results" := Json.Decode.string)

requestSimulation : Simulation -> Task.Task Http.Error RequestResponse
requestSimulation sim =
  let
    convertError = flip Task.onError <| Task.succeed << toString
    url = Http.url "/simulate" []
  in
    post url
      |> withBody (Http.string (Json.Encode.encode 2 (simulationToJson sim)))
      |> withHeader ("Content-Type", "application/json")
      |> send requestResponseDecoder

      -- |> Task.toResult
      -- |> Task.map NewResults
      -- |> Effects.task

requestSimulationResults : RequestResponse -> Task.Task Http.Error SimulationResults
requestSimulationResults reqResponse =
  let
    url = String.concat [reqResponse.url, "/", reqResponse.result_id] |> (flip Http.url) []
  in
    get url
      |> send simulationResultsDecoder
