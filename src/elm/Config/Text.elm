module Config.Text exposing (..)

import Dict exposing (Dict)
import Helpers.Dict exposing (indexedDictFrom)
import Random


randomSuccessMessageIndex : (Int -> msg) -> Cmd msg
randomSuccessMessageIndex msg =
    Random.int 0 (Dict.size successMessages) |> Random.generate msg


getSuccessMessage : Int -> String
getSuccessMessage i =
    let
        ii =
            i % Dict.size successMessages
    in
        Dict.get ii successMessages |> Maybe.withDefault "Amazing!"


successMessages : Dict Int String
successMessages =
    indexedDictFrom 0
        [ "Amazing!"
        , "You're a Hero!"
        , "Incredible!"
        , "You're the best!"
        , "Stunning!"
        ]


failureMessage : String
failureMessage =
    "No more moves!"
