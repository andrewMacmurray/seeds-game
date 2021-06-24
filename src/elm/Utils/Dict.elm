module Utils.Dict exposing
    ( findValue
    , indexedFrom
    , insertWith
    , mapValues
    )

import Dict exposing (Dict)


mapValues : (a -> b) -> Dict comparable a -> Dict comparable b
mapValues f =
    Dict.map (always f)


insertWith : (a -> a -> a) -> comparable -> a -> Dict comparable a -> Dict comparable a
insertWith f k v dict =
    if Dict.member k dict then
        Dict.update k (Maybe.map (\x -> f v x)) dict

    else
        Dict.insert k v dict


indexedFrom : Int -> List a -> Dict Int a
indexedFrom n =
    List.indexedMap (\i x -> ( i + n, x )) >> Dict.fromList


findValue : (a -> Bool) -> Dict comparable a -> Maybe ( comparable, a )
findValue f =
    find (always f)


find : (comparable -> a -> Bool) -> Dict comparable a -> Maybe ( comparable, a )
find predicate =
    let
        findItem_ k v acc =
            case acc of
                Just _ ->
                    acc

                Nothing ->
                    if predicate k v then
                        Just ( k, v )

                    else
                        Nothing
    in
    Dict.foldl findItem_ Nothing
