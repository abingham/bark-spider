module BarkSpider.Model exposing (..)

import Dict
import BarkSpider.Simulation exposing (createSimulation, Parameters, Simulation)


type alias ID =
    Int


type alias ElapsedTime =
    Int


type alias DevelopmentRate =
    Float

{-| This is what we get back when we request that a simulation be run
-}
type alias RequestResponse =
    { url :
        String
        -- The URL at which the results can be fetched
    , result_id :
        String
        -- The ID of the results (append to the url)
    }

{-| The "data" payload of a simulation
-}
type alias SimulationData =
    List ( ElapsedTime, DevelopmentRate )


type SimulationStatus
    = InProgress
    | Success SimulationData
    | Error String


{-| The results for a single simulation, including metadata, parameters, and data.

This is what comes back from the server when we request simulation results.
-}
type alias SimulationResults =
    { name :
        String
        -- Name assigned to the results
    , parameters :
        Parameters
        -- Parameters used to calculate the results
    , status :
        SimulationStatus
        -- The status of the simulation
    }


{-| Top-level model for the app.
-}
type alias Model =
    { simulations : List ( ID, Simulation )
    , results : Dict.Dict Int SimulationResults
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
