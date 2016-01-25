module BarkSpider where

import Html exposing (Html, node, text)
import Html.Attributes exposing (href, rel, src)

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

--
-- update
--

type Input = Nothing

--
-- view
--

stylesheet : String -> Html
stylesheet url = node "link" [ rel "stylesheet", href url] []

script : String -> Html
script url = node "script" [src url] []

view : Signal.Address Input -> Model -> Html
view address model =
  -- let
  --   -- cell_renderer = renderCell
  --   -- grid_size = model.cell_size * model.grid.num_cols
  --   -- elem = renderGrid model.grid grid_size grid_size cell_renderer
  -- in
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
