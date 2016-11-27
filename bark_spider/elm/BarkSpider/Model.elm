module BarkSpider.Model exposing (..)

import Dict
import BarkSpider.Simulation exposing (createSimulation, Parameters, Simulation)
import Monocle.Lens exposing (Lens)


type alias ID =
    Int


type alias URL =
    String


type alias ElapsedTime =
    Int


type alias DevelopmentRate =
    Float


{-| The "data" payload of a simulation
-}
type alias SimulationData =
    List ( ElapsedTime, DevelopmentRate )


type SimulationStatus
    = InProgress URL
    | Success SimulationData
    | Error String


{-| Top-level model for the app.
-}
type alias Model =
    { simulations : List ( ID, Simulation )
    , results : Dict.Dict Int SimulationStatus
    , error_messages : List String
    , next_id : Int
    }


results : Lens Model (Dict.Dict Int SimulationStatus)
results =
    Lens .results (\r m -> { m | results = r })


next_id : Lens Model ID
next_id =
    Lens .next_id (\n m -> { m | next_id = n })


simulations : Lens Model (List ( ID, Simulation ))
simulations =
    Lens .simulations (\s m -> { m | simulations = s })


createModel : Model
createModel =
    let
        sim =
            createSimulation "unnamed"
    in
        { simulations = []
        , results = Dict.empty
        , error_messages = []
        , next_id = 0
        }
