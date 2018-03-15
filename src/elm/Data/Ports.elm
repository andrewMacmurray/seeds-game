port module Data.Ports exposing (..)

import Types exposing (RawProgress, Times)


port scrollToHubLevel : Int -> Cmd msg


port receiveHubLevelOffset : (Float -> msg) -> Sub msg


port getExternalAnimations : Float -> Cmd msg


port receiveExternalAnimations : (String -> msg) -> Sub msg


port cacheProgress : RawProgress -> Cmd msg


port cacheTimes : Times -> Cmd msg


clearCache : Cmd msg
clearCache =
    clearCache_ ()


port clearCache_ : () -> Cmd msg
