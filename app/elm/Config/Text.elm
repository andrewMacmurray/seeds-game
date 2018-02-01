module Config.Text exposing (..)

import Dict exposing (Dict)
import Random


randomSuccessMessage : (String -> msg) -> Cmd msg
randomSuccessMessage msg =
    Random.int 0 (Dict.size successMessages - 1)
        |> Random.map getSuccessMessage
        |> Random.generate msg


getSuccessMessage : Int -> String
getSuccessMessage n =
    Dict.get n successMessages |> Maybe.withDefault "Amazing!"


successMessages : Dict Int String
successMessages =
    [ "Amazing!"
    , "Astounding!"
    , "Incredible!"
    , "Stunning!"
    , "You're a Hero!"
    ]
        |> List.indexedMap (,)
        |> Dict.fromList
