module Helpers.Maybe exposing (catMaybes)


catMaybes : List (Maybe a) -> List a
catMaybes xs =
    List.foldr cat [] xs


cat : Maybe a -> List a -> List a
cat val acc =
    case val of
        Just a ->
            a :: acc

        Nothing ->
            acc
