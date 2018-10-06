module Config.Text exposing (failureMessage, getSuccessMessage, randomSuccessMessageIndex, successMessages)

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
            modBy (Dict.size successMessages) i
    in
    Dict.get ii successMessages |> Maybe.withDefault "Amazing!"


successMessages : Dict Int String
successMessages =
    indexedDictFrom 0
        [ "Amazing!"
        , "Awesome!"
        , "Success!"
        , "Win!"
        ]


failureMessage : String
failureMessage =
    "No more moves!"
