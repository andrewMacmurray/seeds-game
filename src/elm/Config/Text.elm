module Config.Text exposing (failureMessage, getSuccessMessage, successMessages)

import Dict exposing (Dict)
import Helpers.Dict exposing (indexedDictFrom)


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
