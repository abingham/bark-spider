module BarkSpider.Actions (..) where

import BarkSpider.Model
import BarkSpider.Simulation.Actions as BSA
import BarkSpider.Simulation.Model as BSM
import Http


type
  Action
  -- Update the Simulation with the ID
  = Modify BarkSpider.Model.ID BSA.Action
    -- create a new simulation parameter set
  | AddSimulation BSM.Simulation
    -- send parameter sets to server, requesting simulation. Server responds with
    -- retrieval IDs.
  | RunSimulation
    -- simulation results have arrived and should be displayed.
  | NewResults (List (Result Http.Error BarkSpider.Model.SimulationResults))
