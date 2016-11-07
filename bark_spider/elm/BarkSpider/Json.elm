module BarkSpider.Json exposing (..)

import BarkSpider.Model as Model
import BarkSpider.Simulation as Simulation
import Dict
import Json.Decode
import Json.Decode exposing ((:=), andThen, dict, int, float, string)
import Json.Decode.Pipeline exposing (custom, decode, hardcoded, required)
import List
import Result
import String


{-| Convert a Dict with string keys to one with integer keys, lexically
 converting the keys. If a key can't be converted to an int, it gets turned
 into a -1.
-}
toIntKeys : Dict.Dict String a -> Dict.Dict Int a
toIntKeys d =
    Dict.toList d
        |> List.map (\( k, v ) -> ( String.toInt k |> Result.withDefault -1, v ))
        |> Dict.fromList


{-| Decode a JSON string and run it through a converter, returning a default
value if the conversion fail
-}
stringDecoder : a -> (String -> Result b a) -> Json.Decode.Decoder a
stringDecoder default converter =
    Json.Decode.object1
        (converter >> Result.withDefault default)
        Json.Decode.string


{-| Decodes a JSON string and then converts it to a float, or -1.
-}
stringFloatDecoder : Json.Decode.Decoder Float
stringFloatDecoder =
    stringDecoder -1 String.toFloat


{-| Decodes a JSON string and then converts it to a int, or -1.
-}
stringIntDecoder : Json.Decode.Decoder Int
stringIntDecoder =
    stringDecoder -1 String.toInt



--
-- JSON decoders
--


parametersDecoder : Json.Decode.Decoder Simulation.Parameters
parametersDecoder =
    let
        toParameter a t i =
            { assimilation_delay = a
            , training_overhead_proportion = t
            , interventions = i
            }
    in
        decode Simulation.Parameters
            |> required "assimilation_delay" int
            |> required "training_overhead_proportion" float
            |> required "interventions" string



-- This is what we get back as simulation results:
--
-- {"results":
--   {"software_development_rate": {"<step>": "<rate (float)>", . . .},
--    "step_number": {"<step>": "<step>", . . .},
--    "elapsed_time": {"<step>": "<elapsed time (int)>", . . .}},
--  "parameters": {"interventions": "add 100 10", "assimilation_delay": 20, "training_overhead_proportion": 0.25}, "name": "+10 @ 100d"}


simulationDataDecoder : Json.Decode.Decoder Model.SimulationData
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


simulationStatusDecoder : Model.URL -> Json.Decode.Decoder Model.SimulationStatus
simulationStatusDecoder status_url =
    let
        decoder status =
            case status of
                "in-progress" ->
                    decode (Model.InProgress status_url)

                "success" ->
                    decode Model.Success
                        |> custom (Json.Decode.at [ "results" ] simulationDataDecoder)

                "error" ->
                    decode Model.Error
                        |> required "message" string

                _ ->
                    decode (Model.Error "Unknown error")
    in
        ("status" := string) `andThen` decoder
