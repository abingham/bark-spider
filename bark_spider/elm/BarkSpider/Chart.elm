port module BarkSpider.Chart exposing (..)

import BarkSpider.Model as Model


plot : List (Result err Model.SimulationResults) -> Cmd msg
plot results =
    let
        accum next result =
            case next of
                Ok r ->
                    (r.name, r.data) :: result

                _ ->
                    result

        successes =
            List.foldl accum [] results
    in
        render successes


port render : List (String, Model.SimulationData) -> Cmd msg
