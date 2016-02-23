module BarkSpider.App (..) where

import BarkSpider.Model exposing (createModel, Model)
import BarkSpider.Util exposing (noFx)
import BarkSpider.Update exposing (addSimulation, update)
import BarkSpider.View exposing (view)
import BarkSpider.Simulation as Sim
import StartApp


initialModel : Model
initialModel =
  let
    sim =
      Sim.createSimulation "+10 @ 100"
        |> Sim.update (Sim.SetParameter (Sim.SetAssimilationDelay 20))
        |> Sim.update (Sim.SetParameter (Sim.SetTrainingOverheadProportion 0.25))
        |> Sim.update (Sim.SetParameter (Sim.SetInterventions "add 100 10"))
  in
    addSimulation createModel sim


app : StartApp.App Model
app =
  StartApp.start
    { init = noFx initialModel
    , view = view
    , update = update
    , inputs = []
    }
