module BarkSpider.Util where

import Effects exposing (Effects)

-- setAt : List a -> Int -> a -> Maybe (List a)
-- setAt l index value =
--   let
--     head = List.take index l
--     tail = List.drop index l |> List.tail
--   in
--     case tail of
--       Nothing ->
--         Nothing

--       Just t ->
--         Just (value :: t |> List.append head)

-- removeAt : List a -> Int -> List a
-- removeAt l index =
--   let
--     head = List.take index l
--     tail = List.drop index l |> List.tail
--   in
--     case tail of
--       Nothing ->
--         l

--       Just t ->
--         List.append head t

noFx : model -> (model, Effects a)
noFx model = (model, Effects.none)
