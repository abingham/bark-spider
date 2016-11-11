module BarkSpider.Util exposing (distinctColors, distinctColorStrings)

import ParseInt
import String


{-| A sequence of RGB color tuples which are fairly distinct.

These are useful for coloring different data sets. We're mimicking the algorithm
described here:

    http://stackoverflow.com/questions/309149/generate-distinctly-different-rgb-colors-in-graphs
-}
distinctColors : List ( Int, Int, Int )
distinctColors =
    let
        colorBases =
            [ 154, 77, 34, 111, 56, 28, 192, 96, 48, 255, 128, 64 ]

        colorSet base =
            [ ( 0, 0, base ), ( 0, base, 0 ), ( base, 0, 0 ), ( 0, base, base ), ( base, 0, base ), ( base, base, 0 ) ]
    in
        List.map colorSet colorBases |> List.concat


colorToString : ( Int, Int, Int ) -> String
colorToString ( r, g, b ) =
    let
        toHex =
            ParseInt.toHex >> String.append "0" >> String.right 2

        col =
            List.map toHex [ r, g, b ]
    in
        ("#" :: col) |> String.concat


distinctColorStrings : List String
distinctColorStrings =
    List.map colorToString distinctColors
