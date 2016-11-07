module BarkSpider.Model exposing (..)

import Dict
import BarkSpider.Simulation exposing (createSimulation, Parameters, Simulation)


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
