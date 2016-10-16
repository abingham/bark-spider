port module BarkSpider exposing (..)

import BarkSpider.App exposing (app)
-- import Dict
-- import Html
-- import Query
-- import Task


main : Program Never
main =
  app


-- {-| Standard port for letting tasks interact with the native world.
-- -}
-- port tasks : Signal (Task.Task Effects.Never ())
-- port tasks =
--   app.tasks


-- {-| The URL parameter dict provided when the page is invoked.
-- -}
-- parameters : List (String, Maybe String)
-- parameters =
--   Query.parseQuery locationSearch


-- {-| Port for receiving any URL parameters the user provided.
--  -}
-- port locationSearch : (String -> Sub String
