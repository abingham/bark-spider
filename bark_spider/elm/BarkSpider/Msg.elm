module BarkSpider.Msg exposing (..)

import BarkSpider.Model
import BarkSpider.Simulation as Sim
import Http


type
  Msg
  -- Update the Simulation with the ID
  = UpdateSimulation BarkSpider.Model.ID Sim.Msg
    -- create a new simulation parameter set
  | AddSimulation Sim.Simulation
    -- send parameter sets to server, requesting simulation. Server responds with
    -- retrieval IDs.
  | RunSimulation
    -- simulation results have arrived and should be displayed.
  | NewResults (List (Result Http.Error BarkSpider.Model.SimulationResults))
