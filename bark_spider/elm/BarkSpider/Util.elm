module BarkSpider.Util exposing (distinctColors, tuple)

import Monocle.Lens exposing (Lens)


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


{-| Tuple `Lens a b` with `Lens a c` and returns `Lens a (b,c)`

Borrowed from monocle. We should use its version once we can update to 0.18.
-}
tuple : Lens a b -> Lens a c -> Lens a ( b, c )
tuple left right =
    let
        get a =
            ( left.get a, right.get a )

        set ( b, c ) a =
            right.set c (left.set b a)
    in
        Lens get set
