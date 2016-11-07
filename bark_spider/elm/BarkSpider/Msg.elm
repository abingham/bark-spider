module BarkSpider.Msg exposing (..)

import BarkSpider.Model as Model
import BarkSpider.Simulation as Sim
import Http


type
    Msg
    -- Update the Simulation with the ID
    = UpdateSimulation Model.ID Sim.Msg
      -- create a new simulation parameter set
    | AddSimulation Sim.Simulation
      -- send parameter sets to server, requesting simulation. Server responds with
      -- retrieval IDs.
    | RunSimulations
      -- A simulation request has been sucessfully received
    | SimulationSuccess Model.ID Model.RequestResponse
      -- A simulation request has resulted in an error
    | SimulationError Model.ID Http.Error
      -- A simulation's status has been received
    | SimulationStatusSuccess Model.ID Model.SimulationStatus
      -- There has been an error retrieving a simulation's status
    | SimulationStatusError Model.ID Http.Error
