module BarkSpider where

import Effects exposing (Effects)
import Html exposing (Html, node, text)
import Html.Attributes exposing (href, rel, src)

import StartApp

import Bootstrap.Html exposing (colMd_, container_, row_)

--
-- model
--

type alias Parameters =
  { assimilation_delay : Int
  , training_overhead_proportion : Float
  , interventions : String
  }

type alias Simulation =
  { name : String
  , included : Bool
  , parameters : Parameters
  }

type alias Model =
  { simulations : List Simulation
  , error_messages : List String
  }

createModel : Model
createModel =
  { simulations = []
  , error_messages = []
  }

--
-- update
--

type Input = Nothing

update : Input -> Model -> (Model, Effects Input)
update input model =
  let
    m =
      case input of
        Nothing ->
          model
  in
    noFx m

--
-- view
--

stylesheet : String -> Html
stylesheet url = node "link" [ rel "stylesheet", href url] []

script : String -> Html
script url = node "script" [src url] []

view : Signal.Address Input -> Model -> Html
view address model =
    container_
    [ stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"
    , stylesheet "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css"
    , script "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/1.0.2/Chart.min.js"
    , row_
        [colMd_ 2 2 2
           [ text "llamas"
           , text "yaks"
           ]
        , colMd_ 10 10 10
           [ text "emus"
           , text "platypuses...platypi? Not sure."
           ]
        ]
    ]

--
-- Utilities
--

noFx : model -> (model, Effects a)
noFx model = (model, Effects.none)

--
-- Main stuff
--

app : StartApp.App Model
app = StartApp.start
      { init = noFx (createModel)
      , view = view
      , update = update
      , inputs = []
      }

main : Signal Html
main = app.html
