module BarkSpider.Util where

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
