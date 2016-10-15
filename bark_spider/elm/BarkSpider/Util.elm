module BarkSpider.Util exposing (..)

import Color exposing (Color, rgba)
import Platform.Cmd


noFx : model -> ( model, Platform.Cmd.Cmd a )
noFx model =
    ( model, Platform.Cmd.none )


{-| A sequence of color templates which are fairly distinct.

These are useful for coloring different data sets. We're mimicking the algorithm described here:

    http://stackoverflow.com/questions/309149/generate-distinctly-different-rgb-colors-in-graphs
-}
distinctColors : List (Float -> Color)
distinctColors =
    let
        colorBases =
            [ 154, 77, 34, 111, 56, 28, 192, 96, 48, 255, 128, 64 ]

        colorSet base =
            [ (rgba 0 0 base), (rgba 0 base 0), (rgba base 0 0), (rgba 0 base base), (rgba base 0 base), (rgba base base 0) ]
    in
        List.map colorSet colorBases |> List.concat
