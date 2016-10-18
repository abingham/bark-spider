port module BarkSpider.Chart exposing (..)

import BarkSpider.Model as Model
import BarkSpider.Util as Util


type alias ChartData =
    { data : Model.SimulationData
    , name : String
    , color : ( Int, Int, Int )
    }


plot : List (Result err Model.SimulationResults) -> Cmd msg
plot results =
    let
        successes =
            List.foldl
                (\next accum ->
                    case next of
                        Ok r ->
                            r :: accum

                        _ ->
                            accum
                )
                []
                results

        colored =
            List.map2
                (\r color -> { name = r.name, data = r.data, color = color })
                successes
                Util.distinctColors
    in
        render colored


port render : List ChartData -> Cmd msg
