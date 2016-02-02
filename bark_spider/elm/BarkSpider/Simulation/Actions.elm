module BarkSpider.Simulation.Actions where

type ParameterAction
  = SetAssimilationDelay Int
  | SetTrainingOverheadProportion Float
  | SetInterventions String

type Action
  = SetName String
  | SetIncluded Bool
  | SetHidden Bool
  | SetParameter ParameterAction
  | Delete
