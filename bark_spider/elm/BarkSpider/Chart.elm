port module BarkSpider.Chart exposing (..)

import BarkSpider.Model as Model
import BarkSpider.Util as Util
import Dict
import List
import Maybe


type alias ChartData =
    { data : Model.SimulationData
    , name : String
    , color : ( Int, Int, Int )
    }


plottable : Model.Model -> List ( String, Model.SimulationData )
plottable model =
    let
        successes ( id, sim ) sims =
            case Dict.get id model.results of
                Maybe.Just status ->
                    case status of
                        Model.Success data ->
                            ( sim.name, data ) :: sims

                        _ ->
                            sims

                Maybe.Nothing ->
                    sims
    in
        List.foldl successes [] model.simulations


plot : Model.Model -> Cmd msg
plot model =
    let
        colored =
            List.map2
                (\( name, data ) color -> { name = name, data = data, color = color })
                (plottable model)
                Util.distinctColors
    in
        render colored


port render : List ChartData -> Cmd msg
