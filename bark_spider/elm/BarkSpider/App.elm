module BarkSpider.App (..) where

import BarkSpider.Model exposing (createModel, Model)
import BarkSpider.Util exposing (noFx)
import BarkSpider.Update exposing (addSimulation, update)
import BarkSpider.View exposing (view)
import BarkSpider.Simulation.Actions as BSA
import BarkSpider.Simulation.Model as BSM
import BarkSpider.Simulation.Update as BSU
import StartApp


initialModel : Model
initialModel =
  let
    sim =
      BSM.createSimulation "+10 @ 100"
        |> BSU.update (BSA.SetParameter (BSA.SetAssimilationDelay 20))
        |> BSU.update (BSA.SetParameter (BSA.SetTrainingOverheadProportion 0.25))
        |> BSU.update (BSA.SetParameter (BSA.SetInterventions "add 100 10"))
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
