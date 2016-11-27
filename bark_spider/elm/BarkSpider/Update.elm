module BarkSpider.Update exposing (..)

import BarkSpider.Chart as Chart
import BarkSpider.Msg exposing (..)
import BarkSpider.Model as Model
import BarkSpider.Model exposing (results)
import BarkSpider.Comms as Comms
import BarkSpider.Simulation as Sim
import BarkSpider.Util exposing (tuple)
import Dict
import List
import List.Extra exposing (filterNot)
import Monocle.Lens as Lens
import Return exposing (command, effect, map, Return, singleton, zero)
import Time


type alias RType =
    Return Msg Model.Model


type alias RFType =
    RType -> RType


{-| Update the simulation parameters by ID based on an .
-}
updateSimulation : Model.ID -> Sim.Msg -> RFType
updateSimulation id action =
    let
        updateSimulation ( simId, sim ) =
            if simId == id then
                ( simId, Sim.update action sim )
            else
                ( simId, sim )

        newSims =
            case action of
                Sim.Delete ->
                    filterNot (\( simId, _ ) -> simId == id)

                _ ->
                    List.map updateSimulation
    in
        map <| Lens.modify Model.simulations newSims


{-| Add a simulation to a model using the next available ID.
-}
addSimulation : Sim.Simulation -> Model.Model -> Model.Model
addSimulation sim =
    let
        lens =
            tuple Model.next_id Model.simulations
    in
        Lens.modify lens (\( n, s ) -> ( n + 1, s ++ [ ( n, sim ) ] ))


{-| Remove all simulation results from a model.
-}
clearSimulationResults : RFType
clearSimulationResults =
    map <| Lens.modify results (\_ -> Dict.empty)


setStatus : Model.ID -> Model.SimulationStatus -> RFType
setStatus id status =
    map <| Lens.modify results <| Dict.insert id status


fetchResults : Model.ID -> Model.URL -> RFType
fetchResults id status_url =
    command <| Comms.requestSimulationResults id status_url <| Time.second * 0.1


handleSimulateSuccess : Model.ID -> Model.URL -> RFType
handleSimulateSuccess id status_url =
    setStatus id (Model.InProgress status_url)
        >> fetchResults id status_url


handleSimulationSuccess : Model.ID -> Model.SimulationStatus -> RFType
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
                updateSimulation index action

            AddSimulation sim ->
                map <| addSimulation sim

            RunSimulations ->
                clearSimulationResults
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
