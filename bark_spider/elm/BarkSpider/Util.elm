module BarkSpider.Util where

-- TODO: Surely there's a library with this functionality that we can just use.

nth : List a -> Int -> Maybe a
nth l i = List.drop i l |> List.head

setAt : List a -> Int -> a -> Maybe (List a)
setAt l index value =
  let
    head = List.take index l
    tail = List.drop index l |> List.tail
  in
    case tail of
      Nothing ->
        Nothing

      Just t ->
        Just (value :: t |> List.append head)
