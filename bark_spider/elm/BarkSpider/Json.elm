-- Json utilities


module BarkSpider.Json exposing (..)

import Dict
import Json.Decode
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
