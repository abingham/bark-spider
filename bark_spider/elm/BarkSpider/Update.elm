module BarkSpider.Update exposing (..)

import BarkSpider.Chart as Chart
import BarkSpider.Msg exposing (..)
import BarkSpider.Model as Model
import BarkSpider.Comms as Comms
import BarkSpider.Simulation as Sim
import Dict
import List
import List.Extra exposing (filterNot)
import Return exposing (command, effect, map, Return, singleton, zero)
import Time


type alias RType =
    Return Msg Model.Model


{-| Update the simulation parameters by ID based on an .
-}
updateSimulation : Model.ID -> Sim.Msg -> Model.Model -> Model.Model
updateSimulation id action model =
    let
        updateSimulation ( simId, sim ) =
            if simId == id then
                ( simId, Sim.update action sim )
            else
                ( simId, sim )

        matchId ( simId, sim ) =
            simId == id

        sims =
            case action of
                Sim.Delete ->
                    filterNot matchId model.simulations

                _ ->
                    List.map updateSimulation model.simulations
    in
        { model | simulations = sims }


{-| Add a simulation to a model using the next available ID.
-}
addSimulation : Sim.Simulation -> Model.Model -> Model.Model
addSimulation sim model =
    { model
        | simulations = model.simulations ++ [ ( model.next_id, sim ) ]
        , next_id = model.next_id + 1
    }


{-| Remove all simulation results from a model.
-}
clearSimulationResults : Model.Model -> Model.Model
clearSimulationResults model =
    { model
        | results = Dict.empty
    }


setStatus : Model.ID -> Model.SimulationStatus -> RType -> RType
setStatus id status =
    map (\m -> { m | results = Dict.insert id status m.results })


fetchResults : Model.ID -> Model.URL -> RType -> RType
fetchResults id status_url =
    command <| Comms.requestSimulationResults id status_url <| Time.second * 0.1


handleSimulateSuccess : Model.ID -> Model.URL -> RType -> RType
handleSimulateSuccess id status_url =
    setStatus id (Model.InProgress status_url)
        >> fetchResults id status_url


handleSimulationSuccess : Model.ID -> Model.SimulationStatus -> RType -> RType
handleSimulationSuccess id status =
    let
        isComplete s =
            case s of
                Model.Success _ ->
                    True

                Model.Error _ ->
                    True

                _ ->
                    False

        cmd =
            case status of
                Model.InProgress status_url ->
                    fetchResults id status_url

                Model.Success data ->
                    (\( model, cmd ) ->
                        if (List.all isComplete (Dict.values model.results)) then
                            command (Chart.plot model) ( model, cmd )
                        else
                            Return.return model cmd
                    )

                _ ->
                    zero
    in
        setStatus id status >> cmd


{-| Update a model and/or launch effects based on an action.
-}
update : Msg -> Model.Model -> RType
update action model =
    singleton model
        |> case action of
            UpdateSimulation index action ->
                map (updateSimulation index action)

            AddSimulation sim ->
                map (addSimulation sim)

            RunSimulations ->
                map clearSimulationResults
                    >> command (Chart.clear ())
                    >> (\r -> List.foldl command r (Comms.runSimulations model))

            SimulationSuccess id url ->
                handleSimulateSuccess id url

            SimulationError id error ->
                setStatus id (Model.Error error)

            SimulationStatusSuccess id status ->
                handleSimulationSuccess id status

            SimulationStatusError id error ->
                setStatus id (Model.Error error)
