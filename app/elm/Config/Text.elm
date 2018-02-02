module Config.Text exposing (..)

import Dict exposing (Dict)
import Helpers.Dict exposing (indexedDict)


getSuccessMessage : Int -> String
getSuccessMessage n =
    let
        nn =
            n % Dict.size successMessages
    in
        Dict.get nn successMessages |> Maybe.withDefault "Amazing!"


successMessages : Dict Int String
successMessages =
    indexedDict
        [ "Amazing!"
        , "You're a Hero!"
        , "Incredible!"
        , "Astounding!"
        , "You're the best!"
        , "Stunning!"
        ]
